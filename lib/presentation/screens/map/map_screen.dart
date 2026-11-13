import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final state = home.state;
    final car = LatLng(
      state?.latitude ?? 55.7784,
      state?.longitude ?? 37.5865,
    );
    final me = LatLng(car.latitude + 0.0012, car.longitude - 0.0008);
    final mins = state?.age.inMinutes ?? 3;
    final address = state?.address ?? 'Москва, ул. Лесная';

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: car,
                initialZoom: 15,
                backgroundColor: NightDriveColors.graphite,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'ru.sexystarline.sexy_starline',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: me,
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Marker(
                      point: car,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NightDriveColors.cyan.withValues(alpha: 0.25),
                        ),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: NightDriveColors.cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: NightDriveColors.graphite,
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              12 + MediaQuery.paddingOf(context).bottom * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.lastPoint,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '$address · обновлено $mins мин назад',
                  style: const TextStyle(
                    color: NightDriveColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => ref
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
