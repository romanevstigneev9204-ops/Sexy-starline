import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/home/home_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../../domain/entities/command.dart';
import '../../../domain/widgets/home_widget_payload.dart';
import '../../widgets/confirm_sheets.dart';
import '../../widgets/metric_chip.dart';
import '../../widgets/rate_limit_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    Future.microtask(() async {
      await ref.read(homeControllerProvider.notifier).bootstrap();
      ref.read(homeControllerProvider.notifier).setForeground(true);
      ref.invalidate(budgetProvider);
      syncHomeWidget(ref.read);
      await _consumePendingWidgetAction();
    });
  }

  Future<void> _consumePendingWidgetAction() async {
    final pending = ref.read(pendingHomeWidgetActionProvider);
    if (pending == null || pending == HomeWidgetAction.open) {
      if (pending == HomeWidgetAction.open) {
        ref.read(pendingHomeWidgetActionProvider.notifier).state = null;
      }
      return;
    }
    ref.read(pendingHomeWidgetActionProvider.notifier).state = null;
    final cmd = switch (pending) {
      HomeWidgetAction.arm => DeviceCommand.arm,
      HomeWidgetAction.disarm => DeviceCommand.disarm,
      HomeWidgetAction.open => null,
    };
    if (cmd == null || !mounted) return;
    await _onCommand(cmd);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final home = ref.read(homeControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        home.setForeground(true);
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        home.setForeground(false);
    }
  }

  String _freshness(DateTime? updatedAt) {
    if (updatedAt == null) return '—';
    final mins = DateTime.now().difference(updatedAt).inMinutes;
    if (mins <= 0) return '${S.updatedAgo} только что';
    return '${S.updatedAgo} $mins мин назад';
  }

  bool _hasSecondary(HomeController ctrl) {
    return ctrl.canSend(DeviceCommand.quietArm) ||
        ctrl.canSend(DeviceCommand.quietDisarm) ||
        ctrl.canSend(DeviceCommand.panic) ||
        ctrl.canSend(DeviceCommand.valetOn) ||
        ctrl.canSend(DeviceCommand.valetOff);
  }

  bool _hasComfort(HomeController ctrl) {
    return ctrl.canSend(DeviceCommand.webastoOn) ||
        ctrl.canSend(DeviceCommand.webastoOff) ||
        ctrl.canSend(DeviceCommand.auxOn) ||
        ctrl.canSend(DeviceCommand.auxOff);
  }

  Future<void> _onCommand(DeviceCommand cmd) async {
    final home = ref.read(homeControllerProvider.notifier);
    if (cmd == DeviceCommand.disarm || cmd == DeviceCommand.quietDisarm) {
      final ok = await showDisarmConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.start) {
      final ok = await showStartHoldConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.panic) {
      final ok = await showPanicConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.valetOn) {
      final ok = await showValetConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.webastoOn) {
      final ok = await showWebastoConfirm(context);
      if (!ok) return;
    } else if (cmd == DeviceCommand.auxOn) {
      final ok = await showAuxConfirm(context);
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

    ref.listen(geofencesControllerProvider, (prev, next) {
      final alert = next.lastAlert;
      if (alert == null) return;
      if (prev?.lastAlert?.id == alert.id) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alert.bodyRu),
          backgroundColor: NightDriveColors.graphiteElevated,
        ),
      );
      ref.read(geofencesControllerProvider.notifier).clearLastAlert();
    });

    ref.listen<HomeWidgetAction?>(pendingHomeWidgetActionProvider,
        (prev, next) {
      if (next == null || next == HomeWidgetAction.open) return;
      if (!home.hasData || home.loading) return;
      Future.microtask(_consumePendingWidgetAction);
    });

    if (home.rateLimited) {
      return RateLimitView(
        onAck: () =>
            ref.read(homeControllerProvider.notifier).acknowledgeRateLimit(),
      );
    }

    final state = home.state;
    final offline = home.showOffline;
    final ctrl = ref.read(homeControllerProvider.notifier);

    if (home.loading && !home.hasData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: NightDriveColors.cyan),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: NightDriveColors.cyan,
          onRefresh: () async {
            await ref
                .read(homeControllerProvider.notifier)
                .refresh(force: true);
            ref.invalidate(budgetProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              NdLayout.pagePad,
              12,
              NdLayout.pagePad,
              24,
            ),
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
                          offline ? S.noLink : _freshness(state?.updatedAt),
                          style: GoogleFonts.barlow(
                            color: offline
                                ? NightDriveColors.danger
                                : NightDriveColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (home.loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NightDriveColors.cyan,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'devices') context.push('/devices');
                      if (v == 'settings') context.push('/settings');
                      if (v == 'offline') {
                        ref
                            .read(homeControllerProvider.notifier)
                            .previewOffline(!home.forceOfflinePreview);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'devices',
                        child: Text(S.menuDevices),
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: Text(S.menuSettings),
                      ),
                      const PopupMenuItem(
                        value: 'offline',
                        child: Text('Превью офлайн'),
                      ),
                    ],
                  ),
                ],
              ),
              if (home.budgetNearLimit) ...[
                const SizedBox(height: NdLayout.gapMd),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NightDriveColors.graphiteCard,
                    borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                    border: Border.all(
                      color: NightDriveColors.amber.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    S.budgetNearBanner,
                    style: GoogleFonts.barlow(
                      color: NightDriveColors.amber,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
              if (home.error != null && !offline) ...[
                const SizedBox(height: NdLayout.gapMd),
                Text(
                  home.error!,
                  style: const TextStyle(color: NightDriveColors.danger),
                ),
              ],
              const SizedBox(height: NdLayout.gapXl),
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
                    const SizedBox(width: NdLayout.metricGap),
                    MetricChip(
                      label: S.cabin,
                      value: state?.cabinTempC != null
                          ? '${state!.cabinTempC! >= 0 ? '+' : ''}${state.cabinTempC!.round()}°'
                          : '—',
                    ),
                    const SizedBox(width: NdLayout.metricGap),
                    MetricChip(
                      label: S.engineTemp,
                      value: state?.engineTempC != null
                          ? '${state!.engineTempC! >= 0 ? '+' : ''}${state.engineTempC!.round()}°'
                          : '—',
                    ),
                    const SizedBox(width: NdLayout.metricGap),
                    MetricChip(
                      label: S.gsm,
                      value: state?.gsmLevel != null
                          ? '${state!.gsmLevel}/5'
                          : '—',
                    ),
                  ],
                ),
                const SizedBox(height: NdLayout.gapLg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: home.commandBusy ||
                                !ctrl.canSend(
                                  (state?.armed ?? false)
                                      ? DeviceCommand.disarm
                                      : DeviceCommand.arm,
                                )
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
                        onPressed: home.commandBusy ||
                                !ctrl.canSend(
                                  (state?.engineRunning ?? false)
                                      ? DeviceCommand.stop
                                      : DeviceCommand.start,
                                )
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
                  onPressed: home.commandBusy ||
                          !ctrl.canSend(DeviceCommand.horn)
                      ? null
                      : () => _onCommand(DeviceCommand.horn),
                  child: Text(S.horn),
                ),
                if (home.device?.supportsObd == true) ...[
                  const SizedBox(height: NdLayout.gapLg),
                  _ObdSection(deviceId: home.device!.id),
                ],
                if (_hasSecondary(ctrl)) ...[
                  const SizedBox(height: NdLayout.gapLg),
                  Text(
                    S.moreCommands,
                    style: GoogleFonts.archivoNarrow(
                      color: NightDriveColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (state?.valet == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      S.valetActive,
                      style: GoogleFonts.barlow(
                        color: NightDriveColors.amber,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (ctrl.canSend(DeviceCommand.quietArm) ||
                      ctrl.canSend(DeviceCommand.quietDisarm))
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: home.commandBusy ||
                                    !ctrl.canSend(
                                      (state?.armed ?? false)
                                          ? DeviceCommand.quietDisarm
                                          : DeviceCommand.quietArm,
                                    )
                                ? null
                                : () => _onCommand(
                                      (state?.armed ?? false)
                                          ? DeviceCommand.quietDisarm
                                          : DeviceCommand.quietArm,
                                    ),
                            child: Text(
                              (state?.armed ?? false)
                                  ? S.quietDisarm
                                  : S.quietArm,
                            ),
                          ),
                        ),
                        if (ctrl.canSend(DeviceCommand.panic)) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: NightDriveColors.danger,
                                side: BorderSide(
                                  color: NightDriveColors.danger
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              onPressed: home.commandBusy
                                  ? null
                                  : () => _onCommand(DeviceCommand.panic),
                              child: Text(S.panic),
                            ),
                          ),
                        ],
                      ],
                    )
                  else if (ctrl.canSend(DeviceCommand.panic))
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NightDriveColors.danger,
                        side: BorderSide(
                          color:
                              NightDriveColors.danger.withValues(alpha: 0.7),
                        ),
                      ),
                      onPressed: home.commandBusy
                          ? null
                          : () => _onCommand(DeviceCommand.panic),
                      child: Text(S.panic),
                    ),
                  if (ctrl.canSend(DeviceCommand.valetOn) ||
                      ctrl.canSend(DeviceCommand.valetOff)) ...[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: home.commandBusy
                          ? null
                          : () => _onCommand(
                                (state?.valet ?? false)
                                    ? DeviceCommand.valetOff
                                    : DeviceCommand.valetOn,
                              ),
                      child: Text(
                        (state?.valet ?? false) ? S.valetOff : S.valetOn,
                      ),
                    ),
                  ],
                ],
                if (_hasComfort(ctrl)) ...[
                  const SizedBox(height: NdLayout.gapLg),
                  Text(
                    S.comfortCommands,
                    style: GoogleFonts.archivoNarrow(
                      color: NightDriveColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (state?.webasto == true || state?.auxOn == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (state?.webasto == true) S.webastoActive,
                        if (state?.auxOn == true) S.auxActive,
                      ].join(' · '),
                      style: GoogleFonts.barlow(
                        color: NightDriveColors.amber,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (ctrl.canSend(DeviceCommand.webastoOn) ||
                      ctrl.canSend(DeviceCommand.webastoOff)) ...[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: home.commandBusy
                          ? null
                          : () => _onCommand(
                                (state?.webasto ?? false)
                                    ? DeviceCommand.webastoOff
                                    : DeviceCommand.webastoOn,
                              ),
                      child: Text(
                        (state?.webasto ?? false) ? S.webastoOff : S.webastoOn,
                      ),
                    ),
                  ],
                  if (ctrl.canSend(DeviceCommand.auxOn) ||
                      ctrl.canSend(DeviceCommand.auxOff)) ...[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: home.commandBusy
                          ? null
                          : () => _onCommand(
                                (state?.auxOn ?? false)
                                    ? DeviceCommand.auxOff
                                    : DeviceCommand.auxOn,
                              ),
                      child: Text(
                        (state?.auxOn ?? false) ? S.auxOff : S.auxOn,
                      ),
                    ),
                  ],
                ],
              ],
              const SizedBox(height: NdLayout.gapXl),
              budget.when(
                data: (b) => Text(
                  '${S.budgetHomeLabel}: ~${b.requestCount} req сегодня',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlow(
                    color: b.isNearLimit
                        ? NightDriveColors.amber
                        : NightDriveColors.textMuted,
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

class _ObdSection extends ConsumerStatefulWidget {
  const _ObdSection({required this.deviceId});

  final String deviceId;

  @override
  ConsumerState<_ObdSection> createState() => _ObdSectionState();
}

class _ObdSectionState extends ConsumerState<_ObdSection> {
  String? _loadedFor;

  @override
  Widget build(BuildContext context) {
    final obd = ref.watch(obdControllerProvider);
    final deviceId = widget.deviceId;
    if (_loadedFor != deviceId && !obd.loading) {
      _loadedFor = deviceId;
      Future.microtask(
        () => ref.read(obdControllerProvider.notifier).load(deviceId),
      );
    }

    final params = obd.params;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                S.obdSection,
                style: GoogleFonts.archivoNarrow(
                  color: NightDriveColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            if (obd.loading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NightDriveColors.cyan,
                ),
              )
            else
              TextButton(
                onPressed: () async {
                  await ref
                      .read(obdControllerProvider.notifier)
                      .load(deviceId, force: true);
                  ref.invalidate(budgetProvider);
                },
                child: Text(
                  S.obdRefresh,
                  style: GoogleFonts.barlow(
                    color: NightDriveColors.cyan,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (obd.unsupported)
          Text(
            S.obdUnsupported,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textMuted,
              fontSize: 13,
            ),
          )
        else if (params == null || !params.hasAny)
          Text(
            obd.error ?? S.obdEmpty,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textMuted,
              fontSize: 13,
            ),
          )
        else
          Row(
            children: [
              MetricChip(label: S.obdFuel, value: params.fuelLabelRu),
              const SizedBox(width: NdLayout.metricGap),
              MetricChip(label: S.obdMileage, value: params.mileageLabelRu),
              const SizedBox(width: NdLayout.metricGap),
              MetricChip(
                label: S.obdErrors,
                value: params.errorCount?.toString() ?? '—',
              ),
            ],
          ),
      ],
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
        borderRadius: BorderRadius.circular(NdLayout.radiusLg),
        border: Border.all(color: NightDriveColors.cyan.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final t = 0.88 + (math.sin(pulse.value * math.pi) * 0.12);
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
          const SizedBox(height: NdLayout.gapLg),
          Text(
            armed ? S.armed : S.disarmed,
            style: GoogleFonts.archivoNarrow(
              color: NightDriveColors.cyan,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              letterSpacing: 1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: NdLayout.gapSm),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(NdLayout.radiusLg),
            border: Border.all(
              color: NightDriveColors.danger.withValues(alpha: 0.85),
            ),
          ),
          child: Column(
            children: [
              Text(
                S.offline,
                style: GoogleFonts.archivoNarrow(
                  color: NightDriveColors.danger,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: 1.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                S.offlineDetail.replaceAll('{mins}', '$mins'),
                textAlign: TextAlign.center,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NdLayout.gapLg),
        FilledButton(onPressed: onCheck, child: Text(S.checkLink)),
        const SizedBox(height: 10),
        Text(
          S.checkSim,
          textAlign: TextAlign.center,
          style: GoogleFonts.barlow(
            color: NightDriveColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
