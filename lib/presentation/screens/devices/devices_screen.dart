import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  S.devicesTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  S.devicesSubtitle,
                  style: TextStyle(color: NightDriveColors.textSecondary),
                ),
                const SizedBox(height: 20),
                for (final Device d in devices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
    return Material(
      color: NightDriveColors.graphiteCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: device.isShared ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: device.isPrimary
                  ? NightDriveColors.cyan.withValues(alpha: 0.45)
                  : NightDriveColors.stroke,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (device.isShared)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          S.sharedReadonly,
                          style: TextStyle(
                            color: NightDriveColors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Text(
                      device.isShared
                          ? '${device.alias} · ${S.sharedFromOnline}'
                          : device.isPrimary
                              ? '${device.alias} · ${S.devicePrimary}'
                              : device.alias,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!device.isShared) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${device.online ? S.statusOnline : 'Offline'} · GSM ${device.gsmLevel ?? '—'}/5 · ${device.typeName ?? '—'}',
                        style: const TextStyle(
                          color: NightDriveColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (device.isPrimary)
                const Icon(Icons.check, color: NightDriveColors.cyan),
            ],
          ),
        ),
      ),
    );
  }
}
