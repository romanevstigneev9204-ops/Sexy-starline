import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/layout.dart';

class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 12),
        decoration: BoxDecoration(
          color: NightDriveColors.graphiteCard,
          borderRadius: BorderRadius.circular(NdLayout.radiusSm),
          border: Border.all(color: NightDriveColors.stroke.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.barlow(
                color: NightDriveColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.archivoNarrow(
                color: NightDriveColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
