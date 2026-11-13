import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/layout.dart';

Widget _sheetHandle() {
  return Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: NightDriveColors.stroke,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

Future<bool> showDisarmConfirm(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NightDriveColors.graphiteElevated,
    barrierColor: NightDriveColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(NdLayout.radiusSheet),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          NdLayout.pagePad,
          12,
          NdLayout.pagePad,
          20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 22),
            Text(
              S.disarmTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.archivoNarrow(
                color: NightDriveColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.disarmBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                color: NightDriveColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(S.disarmConfirm),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                S.cancel,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

Future<bool> showPanicConfirm(BuildContext context) async {
  return _showSimpleConfirm(
    context,
    title: S.panicTitle,
    body: S.panicBody,
    confirmLabel: S.panicConfirm,
    danger: true,
  );
}

Future<bool> showValetConfirm(BuildContext context) async {
  return _showSimpleConfirm(
    context,
    title: S.valetTitle,
    body: S.valetBody,
    confirmLabel: S.valetConfirm,
  );
}

Future<bool> showWebastoConfirm(BuildContext context) async {
  return _showSimpleConfirm(
    context,
    title: S.webastoTitle,
    body: S.webastoBody,
    confirmLabel: S.webastoConfirm,
  );
}

Future<bool> showAuxConfirm(BuildContext context) async {
  return _showSimpleConfirm(
    context,
    title: S.auxTitle,
    body: S.auxBody,
    confirmLabel: S.auxConfirm,
  );
}

Future<bool> _showSimpleConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool danger = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NightDriveColors.graphiteElevated,
    barrierColor: NightDriveColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(NdLayout.radiusSheet),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          NdLayout.pagePad,
          12,
          NdLayout.pagePad,
          20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.archivoNarrow(
                color: NightDriveColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                color: NightDriveColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: danger
                  ? FilledButton.styleFrom(
                      backgroundColor: NightDriveColors.danger,
                      foregroundColor: NightDriveColors.textPrimary,
                    )
                  : null,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                S.cancel,
                style: GoogleFonts.barlow(
                  color: NightDriveColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

Future<bool> showStartHoldConfirm(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NightDriveColors.graphiteElevated,
    barrierColor: NightDriveColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(NdLayout.radiusSheet),
      ),
    ),
    builder: (ctx) => const _HoldToStartSheet(),
  );
  return result ?? false;
}

class _HoldToStartSheet extends StatefulWidget {
  const _HoldToStartSheet();

  @override
  State<_HoldToStartSheet> createState() => _HoldToStartSheetState();
}

class _HoldToStartSheetState extends State<_HoldToStartSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.pop(context, true);
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NdLayout.pagePad,
        12,
        NdLayout.pagePad,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetHandle(),
          const SizedBox(height: 22),
          Text(
            S.startTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.archivoNarrow(
              color: NightDriveColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.startBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.barlow(
              color: NightDriveColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return GestureDetector(
                onTapDown: (_) => _ctrl.forward(),
                onTapUp: (_) => _ctrl.reverse(),
                onTapCancel: () => _ctrl.reverse(),
                child: SizedBox(
                  height: NdLayout.buttonHeight,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: NightDriveColors.amber),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _ctrl.value,
                            child: const ColoredBox(
                              color: Color(0xFFFFC070),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            S.startHold,
                            style: GoogleFonts.barlow(
                              color: NightDriveColors.graphite,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.cancel,
              style: GoogleFonts.barlow(
                color: NightDriveColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
