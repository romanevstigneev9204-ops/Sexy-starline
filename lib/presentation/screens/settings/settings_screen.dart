import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final budget = ref.watch(budgetProvider);

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
            const _SettingsTile(title: S.theme, subtitle: S.themeValue),
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
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

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
      ),
    );
  }
}
