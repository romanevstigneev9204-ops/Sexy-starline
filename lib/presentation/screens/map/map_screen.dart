import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../widgets/rate_limit_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool _bootstrapped = false;

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);

    if (!_bootstrapped && home.device == null && !home.loading) {
      _bootstrapped = true;
      Future.microtask(
        () => ref.read(homeControllerProvider.notifier).bootstrap(),
      );
    }

    if (home.rateLimited) {
      return RateLimitView(
        onAck: () =>
            ref.read(homeControllerProvider.notifier).acknowledgeRateLimit(),
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

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
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
                      userAgentPackageName: 'ru.sexystarline.sexy_starline',
                    ),
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
                if (home.loading)
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
                if (home.error != null)
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
                          home.error!,
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
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: home.loading
                      ? null
                      : () => ref
                          .read(homeControllerProvider.notifier)
                          .refresh(force: true),
                  child: const Text(S.refreshPosition),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
