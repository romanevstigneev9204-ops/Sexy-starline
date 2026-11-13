import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/command.dart';
import '../../widgets/confirm_sheets.dart';
import '../../widgets/metric_chip.dart';
import '../../widgets/rate_limit_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    Future.microtask(
      () => ref.read(homeControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _freshness(DateTime? updatedAt) {
    if (updatedAt == null) return '—';
    final mins = DateTime.now().difference(updatedAt).inMinutes;
    if (mins <= 0) return '${S.updatedAgo} только что';
    return '${S.updatedAgo} $mins мин назад';
  }

  Future<void> _onCommand(DeviceCommand cmd) async {
    final home = ref.read(homeControllerProvider.notifier);
    if (cmd == DeviceCommand.disarm) {
      final ok = await showDisarmConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.start) {
      final ok = await showStartHoldConfirm(context);
      if (!ok) return;
    }
    final success = await home.sendCommand(cmd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? S.commandOk : S.commandFail)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    final budget = ref.watch(budgetProvider);

    if (home.rateLimited) {
      return RateLimitView(
        onAck: () =>
            ref.read(homeControllerProvider.notifier).acknowledgeRateLimit(),
      );
    }

    final state = home.state;
    final offline = home.showOffline;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: NightDriveColors.cyan,
          onRefresh: () =>
              ref.read(homeControllerProvider.notifier).refresh(force: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.device?.alias ?? '—',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offline
                              ? S.noLink
                              : _freshness(state?.updatedAt),
                          style: TextStyle(
                            color: offline
                                ? NightDriveColors.danger
                                : NightDriveColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: NightDriveColors.graphiteCard,
                    onSelected: (v) {
                      if (v == 'devices') context.push('/devices');
                      if (v == 'settings') context.push('/settings');
                      if (v == 'offline') {
                        ref
                            .read(homeControllerProvider.notifier)
                            .previewOffline(!home.forceOfflinePreview);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'devices',
                        child: Text(S.menuDevices),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: Text(S.menuSettings),
                      ),
                      PopupMenuItem(
                        value: 'offline',
                        child: Text('Превью офлайн'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (offline)
                _OfflineCard(
                  mins: state?.age.inMinutes ?? 42,
                  onCheck: () => ref
                      .read(homeControllerProvider.notifier)
                      .refresh(force: true),
                )
              else
                _StatusCard(
                  pulse: _pulse,
                  armed: state?.armed ?? false,
                  engineOn: state?.engineRunning ?? false,
                  doorsClosed: state?.doorsClosed ?? true,
                  online: state?.online ?? false,
                ),
              if (!offline) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    MetricChip(
                      label: S.battery,
                      value: state?.batteryVolts != null
                          ? '${state!.batteryVolts!.toStringAsFixed(1)} В'
                          : '—',
                    ),
                    const SizedBox(width: 8),
                    MetricChip(
                      label: S.cabin,
                      value: state?.cabinTempC != null
                          ? '${state!.cabinTempC! >= 0 ? '+' : ''}${state.cabinTempC!.round()}°'
                          : '—',
                    ),
                    const SizedBox(width: 8),
                    MetricChip(
                      label: S.engineTemp,
                      value: state?.engineTempC != null
                          ? '${state!.engineTempC! >= 0 ? '+' : ''}${state.engineTempC!.round()}°'
                          : '—',
                    ),
                    const SizedBox(width: 8),
                    MetricChip(
                      label: S.gsm,
                      value: state?.gsmLevel != null
                          ? '${state!.gsmLevel}/5'
                          : '—',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: home.commandBusy
                            ? null
                            : () => _onCommand(
                                  (state?.armed ?? false)
                                      ? DeviceCommand.disarm
                                      : DeviceCommand.arm,
                                ),
                        child: Text(
                          (state?.armed ?? false) ? S.disarm : S.arm,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: NightDriveColors.amber,
                          foregroundColor: NightDriveColors.graphite,
                        ),
                        onPressed: home.commandBusy
                            ? null
                            : () => _onCommand(
                                  (state?.engineRunning ?? false)
                                      ? DeviceCommand.stop
                                      : DeviceCommand.start,
                                ),
                        child: Text(
                          (state?.engineRunning ?? false) ? S.stop : S.start,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: home.commandBusy
                      ? null
                      : () => _onCommand(DeviceCommand.horn),
                  child: const Text(S.horn),
                ),
              ],
              const SizedBox(height: 20),
              budget.when(
                data: (b) => Text(
                  '${S.apiBudget}: ~${b.requestCount} req сегодня',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: NightDriveColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.pulse,
    required this.armed,
    required this.engineOn,
    required this.doorsClosed,
    required this.online,
  });

  final AnimationController pulse;
  final bool armed;
  final bool engineOn;
  final bool doorsClosed;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final detail = [
      engineOn ? S.engineOn : S.engineOff,
      doorsClosed ? S.doorsClosed : S.doorsOpen,
      online ? S.statusOnline : 'Offline',
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: NightDriveColors.graphiteElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NightDriveColors.cyan.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final t = 0.85 + (math.sin(pulse.value * math.pi) * 0.15);
              return Transform.scale(
                scale: t,
                child: Opacity(
                  opacity: 0.55 + pulse.value * 0.45,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: NightDriveColors.cyan, width: 3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            armed ? S.armed : S.disarmed,
            style: const TextStyle(
              color: NightDriveColors.cyan,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: NightDriveColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.mins, required this.onCheck});

  final int mins;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: NightDriveColors.graphiteElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: NightDriveColors.danger.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            children: [
              const Text(
                S.offline,
                style: TextStyle(
                  color: NightDriveColors.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                S.offlineDetail.replaceAll('{mins}', '$mins'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: NightDriveColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onCheck, child: const Text(S.checkLink)),
        const SizedBox(height: 10),
        const Text(
          S.checkSim,
          style: TextStyle(color: NightDriveColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
