import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../../domain/entities/event.dart';
import '../../widgets/rate_limit_view.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String? _loadedFor;

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    final eventsState = ref.watch(eventsControllerProvider);
    final deviceId = home.device?.id;

    if (deviceId == null) {
      if (!home.loading) {
        Future.microtask(
          () => ref.read(homeControllerProvider.notifier).bootstrap(),
        );
      }
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: NightDriveColors.cyan),
        ),
      );
    }

    if (_loadedFor != deviceId) {
      _loadedFor = deviceId;
      Future.microtask(
        () => ref.read(eventsControllerProvider.notifier).load(deviceId),
      );
    }

    if (eventsState.rateLimited) {
      return RateLimitView(
        onAck: () =>
            ref.read(eventsControllerProvider.notifier).acknowledgeRateLimit(),
      );
    }

    final dateLabel =
        '${S.today} · ${DateFormat('d MMMM', 'ru').format(DateTime.now())}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NdLayout.pagePad,
                16,
                NdLayout.pagePad,
                0,
              ),
              child: Text(
                S.eventsTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NdLayout.pagePad),
              child: Row(
                children: [
                  _FilterChip(
                    label: S.filterAll,
                    selected: eventsState.filter == null,
                    onTap: () => ref
                        .read(eventsControllerProvider.notifier)
                        .setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: S.filterAlarms,
                    selected: eventsState.filter == EventKind.alarm,
                    onTap: () => ref
                        .read(eventsControllerProvider.notifier)
                        .setFilter(EventKind.alarm),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: S.filterCommands,
                    selected: eventsState.filter == EventKind.command,
                    onTap: () => ref
                        .read(eventsControllerProvider.notifier)
                        .setFilter(EventKind.command),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NdLayout.gapLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NdLayout.pagePad),
              child: Text(
                dateLabel,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: NdLayout.gapSm),
            if (eventsState.error != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: NdLayout.pagePad),
                child: Text(
                  eventsState.error!,
                  style: const TextStyle(color: NightDriveColors.danger),
                ),
              ),
            Expanded(
              child: eventsState.loading && eventsState.events.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: NightDriveColors.cyan,
                      ),
                    )
                  : RefreshIndicator(
                      color: NightDriveColors.cyan,
                      onRefresh: () => ref
                          .read(eventsControllerProvider.notifier)
                          .load(deviceId, force: true),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          NdLayout.pagePad,
                          0,
                          NdLayout.pagePad,
                          24,
                        ),
                        itemCount: eventsState.visible.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = eventsState.visible[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _colorFor(e.kind, e.title),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: GoogleFonts.barlow(
                                          color: NightDriveColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${S.today}, ${DateFormat('HH:mm').format(e.timestamp)}',
                                        style: GoogleFonts.barlow(
                                          color: NightDriveColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(EventKind kind, String title) {
    final t = title.toLowerCase();
    if (kind == EventKind.alarm) return NightDriveColors.danger;
    if (t.contains('двигател') || t.contains('запущ')) {
      return NightDriveColors.amber;
    }
    if (t.contains('снято') || kind == EventKind.other) {
      return NightDriveColors.textMuted;
    }
    if (kind == EventKind.status || t.contains('охран')) {
      return NightDriveColors.cyan;
    }
    return NightDriveColors.amber;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? NightDriveColors.cyan : NightDriveColors.graphiteCard,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? null
                  : Border.all(color: NightDriveColors.stroke),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                color: selected
                    ? NightDriveColors.graphite
                    : NightDriveColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
