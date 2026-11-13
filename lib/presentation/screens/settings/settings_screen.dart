import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/home/home_controller.dart';
import '../../../application/obd/obd_controller.dart';
import '../../../application/providers.dart';
import '../../../application/theme/theme_preference.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../widgets/confirm_sheets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _obdLoadedFor;

  String _simSubtitle(HomeState home, bool demo) {
    final balance = home.state?.simBalance ?? home.device?.simBalance;
    if (balance == null || !balance.hasValue) {
      return demo
          ? '${S.simBalanceEmpty} · ${S.simBalanceDemoHint}'
          : S.simBalanceEmpty;
    }
    final base = balance.labelRu;
    return demo ? '$base · ${S.simBalanceDemoHint}' : base;
  }

  String _obdSubtitle(ObdState obd, bool demo, bool supports) {
    if (!supports) return S.obdUnsupported;
    if (obd.unsupported) return S.obdUnsupported;
    if (obd.loading && obd.params == null) return '…';
    if (obd.error != null && obd.params == null) return obd.error!;
    final params = obd.params;
    if (params == null || !params.hasAny) {
      return demo ? '${S.obdEmpty} · ${S.obdDemoHint}' : S.obdEmpty;
    }
    final base = params.summaryLabelRu;
    return demo ? '$base · ${S.obdDemoHint}' : base;
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    final budget = ref.watch(budgetProvider);
    final obd = ref.watch(obdControllerProvider);
    final demo = ref.watch(envDemoProvider);
    final themeChoice = ref.watch(themePreferenceProvider);
    final device = home.device;
    final deviceId = device?.id;
    final supportsObd = device?.supportsObd ?? false;

    if (deviceId != null &&
        supportsObd &&
        _obdLoadedFor != deviceId &&
        !obd.loading) {
      _obdLoadedFor = deviceId;
      Future.microtask(
        () => ref.read(obdControllerProvider.notifier).load(deviceId),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NdLayout.pagePad,
            16,
            NdLayout.pagePad,
            24,
          ),
          children: [
            Text(
              S.settingsTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: NdLayout.gapXl),
            _SettingsTile(
              title: S.theme,
              subtitle: themeChoice.settingsLabelRu,
              onTap: () async {
                final picked = await showThemeSheet(
                  context,
                  current: themeChoice,
                );
                if (picked != null && context.mounted) {
                  ref.read(themePreferenceProvider.notifier).state = picked;
                }
              },
            ),
            const SizedBox(height: 10),
            budget.when(
              data: (b) => _SettingsTile(
                title: S.apiLimit,
                subtitle: b.labelRu,
              ),
              loading: () => const _SettingsTile(
                title: S.apiLimit,
                subtitle: '…',
              ),
              error: (_, __) => const _SettingsTile(
                title: S.apiLimit,
                subtitle: '—',
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: S.simBalance,
              subtitle: _simSubtitle(home, demo),
            ),
            if (supportsObd || obd.params != null || obd.unsupported) ...[
              const SizedBox(height: 10),
              _SettingsTile(
                title: S.obdTitle,
                subtitle: _obdSubtitle(obd, demo, supportsObd),
                trailing: supportsObd
                    ? (obd.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: NightDriveColors.cyan,
                            ),
                          )
                        : IconButton(
                            tooltip: S.obdRefresh,
                            onPressed: deviceId == null
                                ? null
                                : () async {
                                    await ref
                                        .read(obdControllerProvider.notifier)
                                        .load(deviceId, force: true);
                                    ref.invalidate(budgetProvider);
                                  },
                            icon: const Icon(
                              Icons.refresh,
                              color: NightDriveColors.cyan,
                              size: 20,
                            ),
                          ))
                    : null,
              ),
            ],
            const SizedBox(height: 10),
            _SettingsTile(
              title: S.devices,
              subtitle:
                  '${home.device?.alias ?? '—'} · ${S.devicePrimary.toLowerCase()}',
              onTap: () => context.push('/devices'),
            ),
            const SizedBox(height: 10),
            const _SettingsTile(title: S.about, subtitle: S.aboutValue),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text(S.logout),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NightDriveColors.graphiteCard,
      borderRadius: BorderRadius.circular(NdLayout.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NdLayout.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NdLayout.radiusMd),
            border: Border.all(color: NightDriveColors.stroke),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.archivoNarrow(
                        color: NightDriveColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.barlow(
                        color: NightDriveColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
