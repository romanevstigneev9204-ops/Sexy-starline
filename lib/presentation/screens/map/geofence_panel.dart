import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
import '../../../domain/entities/geofence.dart';

class GeofencePanel extends ConsumerWidget {
  const GeofencePanel({
    super.key,
    required this.deviceId,
    required this.carLat,
    required this.carLon,
  });

  final String deviceId;
  final double carLat;
  final double carLon;

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Geofence? existing,
  }) async {
    final result = await showModalBottomSheet<Geofence>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NightDriveColors.graphiteElevated,
      barrierColor: NightDriveColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NdLayout.radiusSheet),
        ),
      ),
      builder: (ctx) => _GeofenceEditorSheet(
        deviceId: deviceId,
        carLat: carLat,
        carLon: carLon,
        existing: existing,
      ),
    );
    if (result == null) return;
    await ref.read(geofencesControllerProvider.notifier).save(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geo = ref.watch(geofencesControllerProvider);
    final fences = geo.fences.where((f) => f.deviceId == deviceId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                S.geofencesTitle,
                style: GoogleFonts.archivoNarrow(
                  color: NightDriveColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: fences.isEmpty
                  ? null
                  : () => ref
                      .read(geofencesControllerProvider.notifier)
                      .setOverlayVisible(!geo.overlayVisible),
              child: Text(
                geo.overlayVisible ? S.geofencesHide : S.geofencesShow,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.cyan,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        Text(
          S.geofencesHint,
          style: GoogleFonts.barlow(
            color: NightDriveColors.textMuted,
            fontSize: 11,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        if (fences.isEmpty)
          Text(
            S.geofencesEmpty,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textSecondary,
              fontSize: 13,
            ),
          )
        else
          ...fences.map((fence) {
            final sideLabel = switch (fence.lastSide) {
              GeofenceSide.inside => 'внутри',
              GeofenceSide.outside => 'снаружи',
              GeofenceSide.unknown => '—',
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: NightDriveColors.graphiteCard,
                borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                child: InkWell(
                  onTap: () => _openEditor(context, ref, existing: fence),
                  borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                      border: Border.all(
                        color: fence.enabled
                            ? NightDriveColors.cyan.withValues(alpha: 0.55)
                            : NightDriveColors.stroke,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fence.name,
                                style: GoogleFonts.archivoNarrow(
                                  color: NightDriveColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${fence.radiusMeters.round()} м · $sideLabel',
                                style: GoogleFonts.barlow(
                                  color: NightDriveColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: fence.enabled,
                          activeTrackColor: NightDriveColors.cyan,
                          onChanged: (v) => ref
                              .read(geofencesControllerProvider.notifier)
                              .setEnabled(fence.id, v),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        if (geo.alerts.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            geo.alerts.first.bodyRu,
            style: GoogleFonts.barlow(
              color: NightDriveColors.amber,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _openEditor(context, ref),
          child: const Text(S.geofenceAdd),
        ),
      ],
    );
  }
}

class _GeofenceEditorSheet extends StatefulWidget {
  const _GeofenceEditorSheet({
    required this.deviceId,
    required this.carLat,
    required this.carLon,
    this.existing,
  });

  final String deviceId;
  final double carLat;
  final double carLon;
  final Geofence? existing;

  @override
  State<_GeofenceEditorSheet> createState() => _GeofenceEditorSheetState();
}

class _GeofenceEditorSheetState extends State<_GeofenceEditorSheet> {
  late final TextEditingController _name;
  late double _radius;
  late bool _enter;
  late bool _exit;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? 'Геозона');
    _radius = e?.radiusMeters ?? 250;
    _enter = e?.alertOnEnter ?? true;
    _exit = e?.alertOnExit ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NdLayout.pagePad,
        12,
        NdLayout.pagePad,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NightDriveColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            existing == null ? S.geofenceAdd : S.geofenceEdit,
            textAlign: TextAlign.center,
            style: GoogleFonts.archivoNarrow(
              color: NightDriveColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: S.geofenceNameHint),
          ),
          const SizedBox(height: 16),
          Text(
            '${S.geofenceRadius}: ${_radius.round()}',
            style: GoogleFonts.barlow(
              color: NightDriveColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Slider(
            value: _radius.clamp(50, 2000),
            min: 50,
            max: 2000,
            divisions: 39,
            activeColor: NightDriveColors.cyan,
            onChanged: (v) => setState(() => _radius = v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              S.geofenceEnter,
              style: GoogleFonts.barlow(color: NightDriveColors.textPrimary),
            ),
            value: _enter,
            activeTrackColor: NightDriveColors.cyan,
            onChanged: (v) => setState(() => _enter = v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              S.geofenceExit,
              style: GoogleFonts.barlow(color: NightDriveColors.textPrimary),
            ),
            value: _exit,
            activeTrackColor: NightDriveColors.cyan,
            onChanged: (v) => setState(() => _exit = v),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              final name = _name.text.trim().isEmpty
                  ? 'Геозона'
                  : _name.text.trim();
              final id = existing?.id ??
                  'gf-${widget.deviceId}-${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(
                context,
                Geofence(
                  id: id,
                  deviceId: widget.deviceId,
                  name: name,
                  latitude: existing?.latitude ?? widget.carLat,
                  longitude: existing?.longitude ?? widget.carLon,
                  radiusMeters: _radius,
                  enabled: existing?.enabled ?? true,
                  alertOnEnter: _enter,
                  alertOnExit: _exit,
                  lastSide: existing?.lastSide ?? GeofenceSide.unknown,
                ),
              );
            },
            child: const Text(S.geofenceSave),
          ),
          if (existing != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.maybeOf(context);
                final container = ProviderScope.containerOf(context);
                await container
                    .read(geofencesControllerProvider.notifier)
                    .remove(existing.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                messenger?.showSnackBar(
                  const SnackBar(content: Text(S.geofenceDelete)),
                );
              },
              child: Text(
                S.geofenceDelete,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
