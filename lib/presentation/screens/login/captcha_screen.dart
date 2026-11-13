import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../widgets/brand_mark.dart';

/// Night Drive captcha / SMS confirmation (v1 screenshots).
class CaptchaScreen extends ConsumerStatefulWidget {
  const CaptchaScreen({super.key});

  @override
  ConsumerState<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends ConsumerState<CaptchaScreen> {
  static const _slotCount = 4;

  final _focus = FocusNode();
  final _controller = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 42;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 42);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  String get _code => _controller.text.trim();

  Future<void> _submit() async {
    if (_code.length < _slotCount) return;
    await ref.read(authControllerProvider.notifier).submitExtra(_code);
    final s = ref.read(authControllerProvider);
    if (!mounted) return;
    if (s.status == AuthStatus.authenticated) {
      context.go('/devices');
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    await ref.read(authControllerProvider.notifier).resendExtra();
    if (!mounted) return;
    _controller.clear();
    _startResendCountdown();
    _focus.requestFocus();
  }

  String _mmss(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isSms = auth.needsSms;
    final subtitle = isSms
        ? (auth.maskedPhone == null
            ? S.captchaSmsBody
            : '${S.captchaSmsBody}\n${auth.maskedPhone}')
        : S.captchaBody;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const BrandMark(),
            const SizedBox(height: 28),
            Text(
              S.captchaTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: NightDriveColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _focus.requestFocus(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hidden field drives the 4 visual slots.
                  SizedBox(
                    height: 64,
                    child: TextField(
                      focusNode: _focus,
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      showCursor: false,
                      style: const TextStyle(color: Colors.transparent),
                      cursorColor: Colors.transparent,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-zA-Z]'),
                        ),
                        LengthLimitingTextInputFormatter(_slotCount),
                      ],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slotCount, (i) {
                        final chars = _code.split('');
                        final filled = i < chars.length;
                        final active = i == chars.length && _focus.hasFocus;
                        return Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                          child: _CodeSlot(
                            char: filled ? chars[i] : null,
                            active: active,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 16),
              Text(
                auth.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: NightDriveColors.danger),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton(
              onPressed: auth.busy || _code.length < _slotCount ? null : _submit,
              child: auth.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(S.continueLabel),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: auth.busy || _resendSeconds > 0 ? null : _resend,
              child: Text(
                _resendSeconds > 0
                    ? '${S.resendCode} · ${_mmss(_resendSeconds)}'
                    : S.resendCodeNow,
                style: TextStyle(
                  color: _resendSeconds > 0
                      ? NightDriveColors.textMuted
                      : NightDriveColors.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: auth.busy
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).logout();
                      context.go('/login');
                    },
              child: const Text(
                S.backToLogin,
                style: TextStyle(
                  color: NightDriveColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeSlot extends StatelessWidget {
  const _CodeSlot({required this.char, required this.active});

  final String? char;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final filled = char != null && char!.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 56,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NightDriveColors.graphiteInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? NightDriveColors.cyan
              : filled
                  ? NightDriveColors.stroke
                  : NightDriveColors.stroke.withValues(alpha: 0.7),
          width: active ? 1.5 : 1,
        ),
      ),
      child: filled
          ? Text(
              char!,
              style: const TextStyle(
                color: NightDriveColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            )
          : active
              ? Container(
                  width: 18,
                  height: 2,
                  color: NightDriveColors.cyan,
                )
              : Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: NightDriveColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
    );
  }
}
