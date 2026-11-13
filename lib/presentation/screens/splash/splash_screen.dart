import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../widgets/brand_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: NightDriveColors.graphite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: NightDriveColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
