import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
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
  bool _showCredentials = false;

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
      context.go('/captcha');
    }
  }

  Future<void> _enterDemo() async {
    await ref.read(authControllerProvider.notifier).enterDemo();
    if (!mounted) return;
    if (ref.read(authControllerProvider).status == AuthStatus.authenticated) {
      context.go('/devices');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final demo = ref.watch(envDemoProvider);
    final showForm = !demo || _showCredentials;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NdLayout.pagePad,
            16,
            NdLayout.pagePad,
            24,
          ),
          children: [
            const BrandMark(),
            const SizedBox(height: NdLayout.gapXxl),
            Text(
              S.loginTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: NdLayout.gapSm),
            Text(
              S.loginSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final dy = math.sin(_float.value * math.pi) * 5;
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Container(
                height: 132,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NdLayout.radiusLg),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F2C2B),
                      Color(0xFF121820),
                      Color(0xFF0B0E12),
                    ],
                  ),
                  border: Border.all(
                    color: NightDriveColors.stroke.withValues(alpha: 0.55),
                  ),
                ),
                child: CustomPaint(
                  painter: _StripePainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            if (demo) ...[
              const SizedBox(height: NdLayout.gapLg),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NightDriveColors.graphiteCard,
                  borderRadius: BorderRadius.circular(NdLayout.radiusSm),
                  border: Border.all(
                    color: NightDriveColors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  S.demoBanner,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NightDriveColors.amber,
                        fontSize: 13,
                      ),
                ),
              ),
              const SizedBox(height: NdLayout.gapXl),
              FilledButton(
                onPressed: auth.busy ? null : _enterDemo,
                child: auth.busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NightDriveColors.graphite,
                        ),
                      )
                    : Text(S.loginDemoCta),
              ),
              const SizedBox(height: NdLayout.gapMd),
              if (!showForm)
                OutlinedButton(
                  onPressed: auth.busy
                      ? null
                      : () => setState(() => _showCredentials = true),
                  child: Text(S.loginRealCta),
                ),
            ] else ...[
              const SizedBox(height: NdLayout.gapXl),
            ],
            if (showForm) ...[
              if (demo) const SizedBox(height: NdLayout.gapXl),
              TextField(
                controller: _login,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: S.loginHint),
              ),
              const SizedBox(height: NdLayout.gapMd),
              TextField(
                controller: _password,
                obscureText: true,
                onSubmitted: (_) => _submit(),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: S.passwordHint),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: NdLayout.gapMd),
                Text(
                  auth.error!,
                  style: const TextStyle(color: NightDriveColors.danger),
                ),
              ],
              const SizedBox(height: NdLayout.gapXl),
              if (demo)
                OutlinedButton(
                  onPressed: auth.busy ? null : _submit,
                  child: auth.busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NightDriveColors.cyan,
                          ),
                        )
                      : Text(S.loginCta),
                )
              else
                FilledButton(
                  onPressed: auth.busy ? null : _submit,
                  child: auth.busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NightDriveColors.graphite,
                          ),
                        )
                      : Text(S.loginCta),
                ),
            ] else if (auth.error != null) ...[
              const SizedBox(height: NdLayout.gapMd),
              Text(
                auth.error!,
                style: const TextStyle(color: NightDriveColors.danger),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              S.loginFooter,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (demo && showForm) ...[
              const SizedBox(height: NdLayout.gapMd),
              Text(
                S.demoCaptchaHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      height: 1.35,
                    ),
              ),
            ],
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
      ..color = NightDriveColors.cyan.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 11) {
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
