import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 13.0 : 14.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: compact ? 9 : 11,
            height: compact ? 9 : 11,
            decoration: BoxDecoration(
              color: NightDriveColors.cyan,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
        SizedBox(width: compact ? 8 : 10),
        Text(
          S.appName,
          style: GoogleFonts.archivoNarrow(
            color: NightDriveColors.cyan,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            fontSize: size,
            height: 1,
          ),
        ),
      ],
    );
  }
}
