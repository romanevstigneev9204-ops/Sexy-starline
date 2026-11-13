import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/layout.dart';
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
              S.captchaTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: NdLayout.gapSm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _focus.requestFocus(),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
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
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
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
              const SizedBox(height: NdLayout.gapLg),
              Text(
                auth.error!,
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: NightDriveColors.graphite,
                      ),
                    )
                  : Text(S.continueLabel),
            ),
            const SizedBox(height: NdLayout.gapLg),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: auth.busy || _resendSeconds > 0 ? null : _resend,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _resendSeconds > 0
                      ? '${S.resendCode} · ${_mmss(_resendSeconds)}'
                      : S.resendCodeNow,
                  style: GoogleFonts.barlow(
                    color: _resendSeconds > 0
                        ? NightDriveColors.textMuted
                        : NightDriveColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: NdLayout.gapSm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: auth.busy
                    ? null
                    : () {
                        ref.read(authControllerProvider.notifier).logout();
                        context.go('/login');
                      },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  S.backToLogin,
                  style: GoogleFonts.barlow(
                    color: NightDriveColors.textMuted,
                    fontSize: 13,
                  ),
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
        borderRadius: BorderRadius.circular(NdLayout.radiusSm),
        border: Border.all(
          color: active
              ? NightDriveColors.cyan
              : filled
                  ? NightDriveColors.stroke
                  : NightDriveColors.stroke.withValues(alpha: 0.85),
          width: active ? 1.5 : 1,
        ),
      ),
      child: filled
          ? Text(
              char!,
              style: GoogleFonts.archivoNarrow(
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
