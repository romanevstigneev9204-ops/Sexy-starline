import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);
    final budget = ref.watch(budgetProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              S.settingsTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            const _SettingsTile(title: S.theme, subtitle: S.themeValue),
            const SizedBox(height: 10),
            budget.when(
              data: (b) => _SettingsTile(
                title: S.apiLimit,
                subtitle: '~${b.requestCount} / ${b.dailyLimit} запросов сегодня',
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
                  '${home.device?.alias ?? '—'} · ${S.devicePrimary.toUpperCase()}',
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: NightDriveColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
