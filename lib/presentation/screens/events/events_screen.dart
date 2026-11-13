import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/event.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  EventKind? _filter;

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    final deviceId = home.device?.id;
    if (deviceId == null) {
      return const Scaffold(
        body: Center(child: Text('Нет выбранного устройства')),
      );
    }
    final async = ref.watch(eventsProvider(deviceId));
    final dateLabel =
        '${S.today} · ${DateFormat('d MMMM', 'ru').format(DateTime.now())}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                S.eventsTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: S.filterAll,
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: S.filterAlarms,
                    selected: _filter == EventKind.alarm,
                    onTap: () => setState(() => _filter = EventKind.alarm),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: S.filterCommands,
                    selected: _filter == EventKind.command,
                    onTap: () => setState(() => _filter = EventKind.command),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                dateLabel,
                style: const TextStyle(
                  color: NightDriveColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: async.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: NightDriveColors.cyan),
                ),
                error: (e, _) => Center(child: Text('$e')),
                data: (events) {
                  final filtered = _filter == null
                      ? events
                      : events.where((e) => e.kind == _filter).toList();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorFor(e.kind),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.title,
                                    style: const TextStyle(
                                      color: NightDriveColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${S.today}, ${DateFormat('HH:mm').format(e.timestamp)}',
                                    style: const TextStyle(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(EventKind kind) => switch (kind) {
        EventKind.alarm => NightDriveColors.danger,
        EventKind.command => NightDriveColors.amber,
        EventKind.status => NightDriveColors.cyan,
        EventKind.other => NightDriveColors.textMuted,
      };
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
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
