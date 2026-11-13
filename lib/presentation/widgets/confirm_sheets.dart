import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';

Future<bool> showDisarmConfirm(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NightDriveColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.disarmTitle,
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              S.disarmBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: NightDriveColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(S.disarmConfirm),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                S.cancel,
                style: TextStyle(color: NightDriveColors.textSecondary),
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
        20,
        12,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: NightDriveColors.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.startTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            S.startBody,
            textAlign: TextAlign.center,
            style: TextStyle(color: NightDriveColors.textSecondary),
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
                  height: 52,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                        const Center(
                          child: Text(
                            S.startHold,
                            style: TextStyle(
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              S.cancel,
              style: TextStyle(color: NightDriveColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
