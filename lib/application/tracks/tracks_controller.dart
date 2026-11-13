import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/track.dart';

class TracksState {
  const TracksState({
    this.period,
    this.loading = false,
    this.error,
    this.rateLimited = false,
    this.throttled = false,
    this.overlayVisible = true,
    this.selectedTrackId,
  });

  final TrackPeriod? period;
  final bool loading;
  final String? error;
  final bool rateLimited;
  final bool throttled;
  final bool overlayVisible;
  final String? selectedTrackId;

  List<GpsTrack> get tracks => period?.tracks ?? const [];

  GpsTrack? get selectedTrack {
    final id = selectedTrackId;
    if (id == null) return null;
    for (final t in tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  TracksState copyWith({
    TrackPeriod? period,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? rateLimited,
    bool? throttled,
    bool? overlayVisible,
    String? selectedTrackId,
    bool clearSelected = false,
  }) {
    return TracksState(
      period: period ?? this.period,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      rateLimited: rateLimited ?? this.rateLimited,
      throttled: throttled ?? this.throttled,
      overlayVisible: overlayVisible ?? this.overlayVisible,
      selectedTrackId:
          clearSelected ? null : (selectedTrackId ?? this.selectedTrackId),
    );
  }
}

class TracksController extends StateNotifier<TracksState> {
  TracksController(this._repo) : super(const TracksState());

  final StarlineRepository _repo;

  Future<void> load(
    String deviceId, {
    bool force = false,
    DateTime? begin,
    DateTime? end,
  }) async {
    state = state.copyWith(loading: true, clearError: true, throttled: false);
    try {
      final period = await _repo.tracks(
        deviceId,
        begin: begin,
        end: end,
        force: force,
      );
      state = state.copyWith(
        period: period,
        loading: false,
        rateLimited: _repo.rateLimited,
        throttled: _repo.lastWaysThrottled,
        selectedTrackId: period.tracks.isEmpty
            ? null
            : (state.selectedTrackId ?? period.tracks.first.id),
        clearSelected: period.tracks.isEmpty,
      );
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        rateLimited: e.isRateLimited || _repo.rateLimited,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void selectTrack(String? id) {
    if (id == null) {
      state = state.copyWith(clearSelected: true);
    } else {
      state = state.copyWith(selectedTrackId: id);
    }
  }

  void setOverlayVisible(bool visible) {
    state = state.copyWith(overlayVisible: visible);
  }

  void acknowledgeRateLimit() {
    state = state.copyWith(rateLimited: false);
  }
}
