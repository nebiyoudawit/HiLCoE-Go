import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/form_bits.dart';

/// Shown after sign up (or log in) until the student clicks the link
/// Firebase emailed them.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _message;
  bool _isError = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() => _run(() async {
        final verified = await context.read<AuthState>().refreshVerified();
        if (!verified && mounted) {
          setState(() {
            _message = 'Not verified yet. Open the link in the email, then '
                'tap the button again.';
            _isError = true;
          });
        }
      });

  Future<void> _resend() => _run(() async {
        await context.read<AuthState>().resendVerification();
        if (mounted) {
          setState(() {
            _message = 'Sent again. It can take a minute; check spam too.';
            _isError = false;
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthState, String>((a) => a.user?.email ?? '');
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Row(children: [AppLogo(size: 42)]),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.tint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 44, color: AppColors.blue),
              ),
            ),
            const SizedBox(height: 24),
            Text('Check your email',
                textAlign: TextAlign.center,
                style: AppTheme.display(28, color: AppColors.navy)),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'We sent a verification link to ',
                children: [
                  TextSpan(
                    text: email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const TextSpan(
                      text: '. Open it, then come back and tap the button '
                          'below.'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, height: 1.45, color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            if (_message != null) ...[
              _isError
                  ? FormErrorText(_message!)
                  : Text(_message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.blue)),
              const SizedBox(height: 14),
            ],
            PrimaryButton(
              label: 'I\'ve verified my email',
              busy: _busy,
              onPressed: _check,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : _resend,
              child: const Text('Resend the email'),
            ),
            TextButton(
              onPressed:
                  _busy ? null : () => context.read<AuthState>().logOut(),
              style: TextButton.styleFrom(foregroundColor: AppColors.muted),
              child: const Text('Use a different account'),
            ),
          ],
        ),
      ),
    );
  }
}
