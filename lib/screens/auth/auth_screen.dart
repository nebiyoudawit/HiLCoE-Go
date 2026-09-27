import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../util/validators.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/pill_segments.dart';
import 'auth_hero.dart';

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
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2356E6), Color(0xFF1537B8)],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SafeArea(
                        bottom: false,
                        child: AuthHero(signUp: _mode == AuthMode.signUp),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
              const SizedBox(height: 14),
              mode == AuthMode.logIn
                  ? const _LogInForm(key: ValueKey('login'))
                  : const _SignUpForm(key: ValueKey('signup')),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      mode == AuthMode.logIn
                          ? 'New to HiLCoE Go?'
                          : 'Already have an account?',
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onModeChanged(mode == AuthMode.logIn
                        ? AuthMode.signUp
                        : AuthMode.logIn),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(mode == AuthMode.logIn ? 'Sign up' : 'Log in'),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 14),
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
