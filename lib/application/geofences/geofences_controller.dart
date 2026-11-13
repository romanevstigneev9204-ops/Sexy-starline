import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/geofence_store.dart';
import '../../data/mock/mock_catalog.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/geofence.dart';

class GeofencesState {
  const GeofencesState({
    this.deviceId,
    this.fences = const [],
    this.alerts = const [],
    this.loading = false,
    this.error,
    this.overlayVisible = true,
    this.lastAlert,
  });

  final String? deviceId;
  final List<Geofence> fences;
  final List<GeofenceAlert> alerts;
  final bool loading;
  final String? error;
  final bool overlayVisible;

  /// Latest crossing to surface once in UI (SnackBar), then cleared.
  final GeofenceAlert? lastAlert;

  GeofencesState copyWith({
    String? deviceId,
    List<Geofence>? fences,
    List<GeofenceAlert>? alerts,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? overlayVisible,
    GeofenceAlert? lastAlert,
    bool clearLastAlert = false,
  }) {
    return GeofencesState(
      deviceId: deviceId ?? this.deviceId,
      fences: fences ?? this.fences,
      alerts: alerts ?? this.alerts,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      overlayVisible: overlayVisible ?? this.overlayVisible,
      lastAlert: clearLastAlert ? null : (lastAlert ?? this.lastAlert),
    );
  }
}

/// Client geofences: local CRUD + evaluate crossings on cached GPS polls.
///
/// Does **not** call StarLine geofence APIs (none assumed) and does not
/// issue extra position requests — uses Home/state refresh budget only.
class GeofencesController extends StateNotifier<GeofencesState> {
  GeofencesController({
    required GeofenceStore store,
    required bool useMock,
  })  : _store = store,
        _useMock = useMock,
        super(const GeofencesState());

  final GeofenceStore _store;
  final bool _useMock;

  static const _maxAlerts = 20;

  Future<void> load(String deviceId, {bool seedDemoIfEmpty = true}) async {
    state = state.copyWith(loading: true, clearError: true, deviceId: deviceId);
    try {
      var fences = await _store.listForDevice(deviceId);
      if (fences.isEmpty && seedDemoIfEmpty && _useMock) {
        fences = MockCatalog.geofencesFor(deviceId);
        await _store.upsertAll(fences);
      }
      state = state.copyWith(
        fences: fences,
        loading: false,
        deviceId: deviceId,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> save(Geofence fence) async {
    await _store.upsert(fence);
    final deviceId = fence.deviceId;
    final next = [
      for (final f in state.fences)
        if (f.id != fence.id) f,
      fence,
    ]..sort((a, b) => a.name.compareTo(b.name));
    state = state.copyWith(fences: next, deviceId: deviceId, clearError: true);
  }

  Future<void> remove(String id) async {
    await _store.delete(id);
    state = state.copyWith(
      fences: state.fences.where((f) => f.id != id).toList(growable: false),
    );
  }

  Future<void> setEnabled(String id, bool enabled) async {
    Geofence? target;
    for (final f in state.fences) {
      if (f.id == id) {
        target = f;
        break;
      }
    }
    if (target == null) return;
    final updated = target.copyWith(enabled: enabled);
    await save(updated);
  }

  void setOverlayVisible(bool value) {
    state = state.copyWith(overlayVisible: value);
  }

  void clearLastAlert() {
    state = state.copyWith(clearLastAlert: true);
  }

  /// Evaluate fences against a state snapshot (from existing poll — 0 extra req).
  Future<List<GeofenceAlert>> evaluate(DeviceState ds) async {
    final lat = ds.latitude;
    final lon = ds.longitude;
    if (lat == null || lon == null) return const [];

    if (state.deviceId != ds.deviceId) {
      await load(ds.deviceId);
    }

    final now = DateTime.now();
    final newAlerts = <GeofenceAlert>[];
    final updated = <Geofence>[];

    for (final fence in state.fences) {
      if (fence.deviceId != ds.deviceId || !fence.enabled) {
        updated.add(fence);
        continue;
      }
      final inside = GeofenceMath.isInside(fence, lat: lat, lon: lon);
      final side = inside ? GeofenceSide.inside : GeofenceSide.outside;
      final cross = GeofenceMath.crossing(
        previous: fence.lastSide,
        nowInside: inside,
      );
      var next = fence.copyWith(lastSide: side);
      if (cross != null) {
        final allow = (cross == GeofenceCrossing.enter && fence.alertOnEnter) ||
            (cross == GeofenceCrossing.exit && fence.alertOnExit);
        if (allow) {
          newAlerts.add(
            GeofenceAlert(
              id: 'ga-${fence.id}-${now.millisecondsSinceEpoch}',
              geofenceId: fence.id,
              geofenceName: fence.name,
              deviceId: fence.deviceId,
              crossing: cross,
              at: now,
            ),
          );
        }
      }
      if (next.lastSide != fence.lastSide) {
        await _store.updateLastSide(fence.id, side);
      }
      updated.add(next);
    }

    final alerts = newAlerts.isEmpty
        ? state.alerts
        : [...newAlerts.reversed, ...state.alerts]
            .take(_maxAlerts)
            .toList(growable: false);

    state = state.copyWith(
      fences: updated,
      alerts: alerts,
      lastAlert: newAlerts.isEmpty ? state.lastAlert : newAlerts.last,
    );
    return newAlerts;
  }

  /// Demo helper: force a synthetic exit/enter for UI without moving GPS.
  Future<GeofenceAlert?> simulateCrossing(String fenceId) async {
    Geofence? fence;
    for (final f in state.fences) {
      if (f.id == fenceId) {
        fence = f;
        break;
      }
    }
    if (fence == null) return null;
    final nowInside = fence.lastSide != GeofenceSide.inside;
    final cross = nowInside ? GeofenceCrossing.enter : GeofenceCrossing.exit;
    final side = nowInside ? GeofenceSide.inside : GeofenceSide.outside;
    final updated = fence.copyWith(lastSide: side);
    await _store.upsert(updated);
    final alert = GeofenceAlert(
      id: 'ga-sim-${fence.id}-${DateTime.now().millisecondsSinceEpoch}',
      geofenceId: fence.id,
      geofenceName: fence.name,
      deviceId: fence.deviceId,
      crossing: cross,
      at: DateTime.now(),
    );
    final fences = [
      for (final f in state.fences)
        if (f.id == fence.id) updated else f,
    ];
    state = state.copyWith(
      fences: fences,
      alerts: [alert, ...state.alerts].take(_maxAlerts).toList(),
      lastAlert: alert,
    );
    return alert;
  }
}
