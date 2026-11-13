import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../application/providers.dart';
import '../../../application/tracks/tracks_controller.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../../domain/entities/track.dart';
import '../../widgets/rate_limit_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _bootstrapped = false;
  String? _tracksLoadedFor;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadTracks(String deviceId, {bool force = false}) async {
    await ref.read(tracksControllerProvider.notifier).load(
          deviceId,
          force: force,
        );
    ref.invalidate(budgetProvider);
  }

  void _fitTrack(GpsTrack track) {
    if (track.points.isEmpty) return;
    final pts = track.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    if (pts.length == 1) {
      _mapController.move(pts.first, 15);
      return;
    }
    var minLat = pts.first.latitude;
    var maxLat = pts.first.latitude;
    var minLon = pts.first.longitude;
    var maxLon = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }
    final bounds = LatLngBounds(
      LatLng(minLat, minLon),
      LatLng(maxLat, maxLon),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    final tracksState = ref.watch(tracksControllerProvider);

    if (!_bootstrapped && home.device == null && !home.loading) {
      _bootstrapped = true;
      Future.microtask(
        () => ref.read(homeControllerProvider.notifier).bootstrap(),
      );
    }

    final deviceId = home.device?.id;
    final canTracks = home.device?.supportsTracks ?? false;
    if (deviceId != null &&
        canTracks &&
        _tracksLoadedFor != deviceId &&
        !tracksState.loading) {
      _tracksLoadedFor = deviceId;
      Future.microtask(() => _loadTracks(deviceId));
    }

    if (home.rateLimited || tracksState.rateLimited) {
      return RateLimitView(
        onAck: () {
          ref.read(homeControllerProvider.notifier).acknowledgeRateLimit();
          ref.read(tracksControllerProvider.notifier).acknowledgeRateLimit();
        },
      );
    }

    final state = home.state;
    final car = LatLng(
      state?.latitude ?? 55.7784,
      state?.longitude ?? 37.5865,
    );
    final me = LatLng(car.latitude + 0.0012, car.longitude - 0.0008);
    final mins = state?.age.inMinutes ?? 0;
    final address = state?.address ?? 'Координаты авто';
    final hasFix = state?.latitude != null && state?.longitude != null;

    final selected = tracksState.selectedTrack;
    final polylines = <Polyline>[];
    if (tracksState.overlayVisible) {
      for (final track in tracksState.tracks) {
        if (!track.hasGeometry) continue;
        final isSelected = selected?.id == track.id;
        polylines.add(
          Polyline(
            points: track.points
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList(growable: false),
            strokeWidth: isSelected ? 4.5 : 3,
            color: isSelected
                ? NightDriveColors.cyan
                : NightDriveColors.cyan.withValues(alpha: 0.35),
          ),
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: car,
                    initialZoom: 15,
                    backgroundColor: NightDriveColors.graphite,
                  ),
                  children: [
                    TileLayer(
                      // Dark Night Drive base (CartoDB Dark Matter).
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'ru.sexystarline.app',
                    ),
                    if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: me,
                          width: 14,
                          height: 14,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NightDriveColors.textSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NightDriveColors.graphite,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Marker(
                          point: car,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NightDriveColors.cyan.withValues(
                                alpha: 0.18,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: NightDriveColors.cyan,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: NightDriveColors.cyan.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (home.loading || tracksState.loading)
                  const Positioned(
                    top: 48,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NightDriveColors.cyan,
                        ),
                      ),
                    ),
                  ),
                if (home.error != null || tracksState.error != null)
                  Positioned(
                    top: 48,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: NightDriveColors.graphiteCard,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          home.error ?? tracksState.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: NightDriveColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: NightDriveColors.graphite,
            padding: const EdgeInsets.fromLTRB(
              NdLayout.pagePad,
              16,
              NdLayout.pagePad,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.lastPoint,
                  style: GoogleFonts.archivoNarrow(
                    color: NightDriveColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasFix
                      ? '$address · обновлено $mins мин назад'
                      : 'Нет координат · потяните обновление',
                  style: GoogleFonts.barlow(
                    color: NightDriveColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: home.loading
                      ? null
                      : () => ref
                          .read(homeControllerProvider.notifier)
                          .refresh(force: true),
                  child: const Text(S.refreshPosition),
                ),
                if (canTracks && deviceId != null) ...[
                  const SizedBox(height: 16),
                  _TracksPanel(
                    tracksState: tracksState,
                    onToggleOverlay: () => ref
                        .read(tracksControllerProvider.notifier)
                        .setOverlayVisible(!tracksState.overlayVisible),
                    onRefresh: tracksState.loading
                        ? null
                        : () => _loadTracks(deviceId, force: true),
                    onSelect: (track) {
                      ref
                          .read(tracksControllerProvider.notifier)
                          .selectTrack(track.id);
                      if (tracksState.overlayVisible) {
                        _fitTrack(track);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TracksPanel extends StatelessWidget {
  const _TracksPanel({
    required this.tracksState,
    required this.onToggleOverlay,
    required this.onRefresh,
    required this.onSelect,
  });

  final TracksState tracksState;
  final VoidCallback onToggleOverlay;
  final VoidCallback? onRefresh;
  final ValueChanged<GpsTrack> onSelect;

  @override
  Widget build(BuildContext context) {
    final tracks = tracksState.tracks;
    final dateLabel = DateFormat('d MMMM', 'ru').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${S.tracksTitle} · $dateLabel',
                style: GoogleFonts.archivoNarrow(
                  color: NightDriveColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: tracks.isEmpty ? null : onToggleOverlay,
              child: Text(
                tracksState.overlayVisible ? S.tracksHide : S.tracksShow,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.cyan,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        Text(
          S.tracksBudgetHint,
          style: GoogleFonts.barlow(
            color: NightDriveColors.textMuted,
            fontSize: 11,
            height: 1.3,
          ),
        ),
        if (tracksState.throttled) ...[
          const SizedBox(height: 6),
          Text(
            S.tracksThrottle,
            style: GoogleFonts.barlow(
              color: NightDriveColors.amber,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (tracks.isEmpty && !tracksState.loading)
          Text(
            S.tracksEmpty,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textSecondary,
              fontSize: 13,
            ),
          )
        else
          ...tracks.map((track) {
            final selected = tracksState.selectedTrackId == track.id;
            final start = track.startedAt;
            final timeLabel = start == null
                ? '—'
                : DateFormat('HH:mm', 'ru').format(start);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? NightDriveColors.graphiteElevated
                    : NightDriveColors.graphiteCard,
                borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                child: InkWell(
                  onTap: () => onSelect(track),
                  borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                      border: Border.all(
                        color: selected
                            ? NightDriveColors.cyan.withValues(alpha: 0.7)
                            : NightDriveColors.stroke,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          timeLabel,
                          style: GoogleFonts.archivoNarrow(
                            color: NightDriveColors.cyan,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${S.trackMileage} ${track.mileageLabelRu} · '
                            '${S.trackDuration} ${track.durationLabelRu}',
                            style: GoogleFonts.barlow(
                              color: NightDriveColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        OutlinedButton(
          onPressed: onRefresh,
          child: const Text(S.tracksRefresh),
        ),
      ],
    );
  }
}
