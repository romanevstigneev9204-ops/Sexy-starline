import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/brand_mark.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _login = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.login(_login.text.trim(), _password.text);
    final state = ref.read(authControllerProvider);
    if (!mounted) return;
    if (state.status == AuthStatus.authenticated) {
      context.go('/devices');
    } else if (state.status == AuthStatus.needsExtra) {
      context.push('/captcha');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final demo = ref.watch(envDemoProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const BrandMark(),
            const SizedBox(height: 28),
            Text(
              S.loginTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              S.loginSubtitle,
              style: TextStyle(
                color: NightDriveColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final dy = math.sin(_float.value * math.pi) * 6;
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E2A2A),
                      Color(0xFF142028),
                      Color(0xFF0B0E12),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _StripePainter(),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_filled_outlined,
                      color: NightDriveColors.cyan,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            if (demo) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NightDriveColors.graphiteCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NightDriveColors.amber.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  S.demoBanner,
                  style: TextStyle(
                    color: NightDriveColors.amber,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _login,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: S.loginHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(hintText: S.passwordHint),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: const TextStyle(color: NightDriveColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.busy ? null : _submit,
              child: auth.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(S.loginCta),
            ),
            if (demo) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: auth.busy
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .enterDemo();
                        if (context.mounted) context.go('/devices');
                      },
                child: const Text(S.loginDemoCta),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              S.loginFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NightDriveColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NightDriveColors.cyan.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
