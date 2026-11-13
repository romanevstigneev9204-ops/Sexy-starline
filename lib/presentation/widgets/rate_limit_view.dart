import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/colors.dart';

class RateLimitView extends StatelessWidget {
  const RateLimitView({super.key, required this.onAck});

  final VoidCallback onAck;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NightDriveColors.amber),
              ),
              child: const Text(
                S.rateLimitBadge,
                style: TextStyle(
                  color: NightDriveColors.amber,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.rateLimitTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              S.rateLimitBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NightDriveColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onAck,
              child: const Text(S.rateLimitCta),
            ),
          ],
        ),
      ),
    );
  }
}
