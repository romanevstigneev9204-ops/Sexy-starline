import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: compact ? 10 : 12,
            height: compact ? 10 : 12,
            decoration: BoxDecoration(
              color: NightDriveColors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          S.appName,
          style: TextStyle(
            color: NightDriveColors.cyan,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: compact ? 13 : 14,
          ),
        ),
      ],
    );
  }
}
