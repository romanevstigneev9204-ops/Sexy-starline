import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../../domain/entities/device.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(devicesProvider);

    return Scaffold(
      body: SafeArea(
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: NightDriveColors.cyan),
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (devices) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                NdLayout.pagePad,
                16,
                NdLayout.pagePad,
                24,
              ),
              children: [
                Text(
                  S.devicesTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: NdLayout.gapSm),
                Text(
                  S.devicesSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: NdLayout.gapXl),
                for (final Device d in devices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: NdLayout.gapMd),
                    child: _DeviceCard(
                      device: d,
                      onTap: () async {
                        await ref
                            .read(homeControllerProvider.notifier)
                            .selectDevice(d);
                        if (context.mounted) context.go('/home');
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onTap});

  final Device device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = device.isPrimary && !device.isShared;
    final borderColor = selected
        ? NightDriveColors.cyan.withValues(alpha: 0.85)
        : NightDriveColors.stroke;

    return Material(
      color: NightDriveColors.graphiteCard,
      borderRadius: BorderRadius.circular(NdLayout.radiusMd),
      child: InkWell(
        onTap: device.isShared ? null : onTap,
        borderRadius: BorderRadius.circular(NdLayout.radiusMd),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NdLayout.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (device.isShared) ...[
                      Text(
                        S.sharedReadonly,
                        style: GoogleFonts.archivoNarrow(
                          color: NightDriveColors.amber,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${device.alias} · ${S.sharedFromOnline}',
                        style: GoogleFonts.barlow(
                          color: NightDriveColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ] else ...[
                      Text(
                        device.isPrimary
                            ? '${device.alias} · ${S.devicePrimary}'
                            : device.alias,
                        style: GoogleFonts.archivoNarrow(
                          color: NightDriveColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${device.online ? S.statusOnline : 'Offline'} · GSM ${device.gsmLevel ?? '—'}/5 · ${device.typeName ?? '—'}',
                        style: GoogleFonts.barlow(
                          color: NightDriveColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check, color: NightDriveColors.cyan, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
