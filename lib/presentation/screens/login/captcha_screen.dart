import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/providers.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/colors.dart';

class CaptchaScreen extends ConsumerStatefulWidget {
  const CaptchaScreen({super.key});

  @override
  ConsumerState<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends ConsumerState<CaptchaScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(S.captchaTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              auth.needsSms
                  ? 'Введите код из SMS'
                  : 'Пройдите captcha / введите код',
              style: const TextStyle(color: NightDriveColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: S.captchaHint),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.busy
                  ? null
                  : () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .submitExtra(_code.text.trim());
                      final s = ref.read(authControllerProvider);
                      if (context.mounted &&
                          s.status == AuthStatus.authenticated) {
                        context.go('/devices');
                      }
                    },
              child: const Text(S.continueLabel),
            ),
          ],
        ),
      ),
    );
  }
}
