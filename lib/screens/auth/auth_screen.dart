import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/validators.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/pill_segments.dart';

enum AuthMode { logIn, signUp }

/// Blue welcome area on top, white sheet with the Log in / Sign up form
/// below, matching the Login and Signup mockups.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.logIn;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.blue,
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SafeArea(
                      bottom: false,
                      child: _Hero(mode: _mode),
                    ),
                  ),
                  _Sheet(
                    mode: _mode,
                    onModeChanged: (mode) => setState(() => _mode = mode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final logIn = mode == AuthMode.logIn;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(),
              const Spacer(),
              if (!logIn) const _BatchChip(),
            ],
          ),
          const SizedBox(height: 16),
          if (logIn) const _FloatingCards(),
          const Spacer(),
          const SizedBox(height: 16),
          Text(
            logIn ? 'Your whole term,\nin one place.' : 'Join HiLCoE Go',
            style: AppTheme.display(logIn ? 36 : 34, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            logIn
                ? 'Classes, grades, exams and attendance for HiLCoE students.'
                : 'Set up your account in under a minute.',
            style: const TextStyle(fontSize: 15, color: AppColors.onBlueMuted),
          ),
        ],
      ),
    );
  }
}

/// Decorative cards hinting at what the app tracks.
class _FloatingCards extends StatelessWidget {
  const _FloatingCards();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 4,
              top: 8,
              child: _tilted(
                -4,
                _card(
                  color: Colors.white,
                  shadow: true,
                  child: const _TwoLine(
                    top: 'NOW · 9:45',
                    bottom: 'MATH 211 · Room 202',
                    topColor: AppColors.blue,
                    bottomColor: AppColors.ink,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _tilted(
                5,
                _card(
                  color: AppColors.navy,
                  shadow: true,
                  child: const _TwoLine(
                    top: 'MID EXAM',
                    bottom: 'in 28 days',
                    topColor: AppColors.onBlueMuted,
                    bottomColor: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 96,
              child: _tilted(3, _glass('2 / 5 absences', pill: true)),
            ),
            Positioned(
              right: 30,
              top: 86,
              child: _tilted(-2, _glass('Quiz 2 · 4 / 5')),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tilted(double degrees, Widget child) =>
      Transform.rotate(angle: degrees * 3.14159 / 180, child: child);

  static Widget _card({
    required Color color,
    required Widget child,
    bool shadow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color(0x380F172A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  static Widget _glass(String text, {bool pill = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: pill ? 12 : 14,
        vertical: pill ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(pill ? 999 : 14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: pill ? 13 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TwoLine extends StatelessWidget {
  const _TwoLine({
    required this.top,
    required this.bottom,
    required this.topColor,
    required this.bottomColor,
  });

  final String top;
  final String bottom;
  final Color topColor;
  final Color bottomColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(top, style: AppTheme.eyebrow(color: topColor, size: 11)),
        const SizedBox(height: 2),
        Text(
          bottom,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: bottomColor,
          ),
        ),
      ],
    );
  }
}

class _BatchChip extends StatelessWidget {
  const _BatchChip();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: 5 * 3.14159 / 180,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x380F172A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BATCH', style: AppTheme.eyebrow(size: 10)),
              const Text(
                'DRB2301',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.mode, required this.onModeChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              PillSegments<AuthMode>(
                values: AuthMode.values,
                selected: mode,
                labelOf: (m) => m == AuthMode.logIn ? 'Log in' : 'Sign up',
                onChanged: onModeChanged,
                background: AppColors.tint,
                height: 42,
              ),
              const SizedBox(height: 16),
              mode == AuthMode.logIn
                  ? const _LogInForm(key: ValueKey('login'))
                  : const _SignUpForm(key: ValueKey('signup')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogInForm extends StatefulWidget {
  const _LogInForm({super.key});

  @override
  State<_LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<_LogInForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AuthState>()
          .logIn(email: _email.text, password: _password.text);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledField(
              label: 'Email',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: validateEmail,
                decoration:
                    const InputDecoration(hintText: 'Your email address'),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Password',
              child: PasswordField(
                controller: _password,
                hint: 'Your password',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your password' : null,
                onSubmitted: _submit,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              FormErrorText(_error!),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Log in',
              arrow: true,
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _batch = TextEditingController();
  final _studentId = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _batch.dispose();
    _studentId.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().signUp(
            name: _name.text,
            email: _email.text,
            batch: _batch.text,
            studentId: _studentId.text,
            password: _password.text,
          );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledField(
              label: 'Full name',
              child: TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                validator: requiredText('your name'),
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Email',
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: validateEmail,
                decoration:
                    const InputDecoration(hintText: 'Your email address'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    label: 'Batch',
                    child: TextFormField(
                      controller: _batch,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: validateBatch,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. DRB2301',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    label: 'Student ID',
                    hint: '(opt.)',
                    child: TextFormField(
                      controller: _studentId,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'Your ID'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LabeledField(
              label: 'Password',
              child: PasswordField(
                controller: _password,
                hint: 'At least 8 characters',
                newPassword: true,
                validator: validateNewPassword,
                onSubmitted: _submit,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              FormErrorText(_error!),
            ],
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Create account',
              arrow: true,
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
