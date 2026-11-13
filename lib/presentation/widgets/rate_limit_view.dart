import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/layout.dart';

class RateLimitView extends StatelessWidget {
  const RateLimitView({super.key, required this.onAck});

  final VoidCallback onAck;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NightDriveColors.amber),
                  ),
                  child: Text(
                    S.rateLimitBadge,
                    style: GoogleFonts.archivoNarrow(
                      color: NightDriveColors.amber,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  S.rateLimitTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivoNarrow(
                    color: NightDriveColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  S.rateLimitBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlow(
                    color: NightDriveColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(NdLayout.buttonHeight),
                    ),
                    onPressed: onAck,
                    child: const Text(S.rateLimitCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
