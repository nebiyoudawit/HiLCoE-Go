import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/auth_repository.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/validators.dart';
import '../../widgets/form_bits.dart';

/// Change name, batch and student ID, or the account password.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 26),
          label: const Text('Back'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text('Profile', style: AppTheme.display(30)),
            const SizedBox(height: 18),
            const _DetailsForm(),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Change password',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const _PasswordForm(),
          ],
        ),
      ),
    );
  }
}

void _toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class _DetailsForm extends StatefulWidget {
  const _DetailsForm();

  @override
  State<_DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends State<_DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _batch;
  late final TextEditingController _studentId;
  late final String _email;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthState>().user!;
    _name = TextEditingController(text: user.name);
    _batch = TextEditingController(text: user.batch);
    _studentId = TextEditingController(text: user.studentId);
    _email = user.email;
  }

  @override
  void dispose() {
    _name.dispose();
    _batch.dispose();
    _studentId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().updateProfile(
            name: _name.text,
            batch: _batch.text,
            studentId: _studentId.text,
          );
      if (mounted) _toast(context, 'Profile saved');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Full name',
            child: TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: requiredText('your name'),
            ),
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: 'Email',
            hint: '(can\'t be changed)',
            child: TextFormField(
              initialValue: _email,
              enabled: false,
              style: const TextStyle(color: AppColors.muted),
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
                    textInputAction: TextInputAction.next,
                    validator: validateBatch,
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
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            FormErrorText(_error!),
          ],
          const SizedBox(height: 18),
          PrimaryButton(label: 'Save profile', busy: _busy, onPressed: _save),
        ],
      ),
    );
  }
}

class _PasswordForm extends StatefulWidget {
  const _PasswordForm();

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AuthState>()
          .changePassword(current: _current.text, next: _next.text);
      _current.clear();
      _next.clear();
      if (mounted) _toast(context, 'Password changed');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'Current password',
            child: PasswordField(
              controller: _current,
              hint: 'Your current password',
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Enter your current password'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: 'New password',
            child: PasswordField(
              controller: _next,
              hint: 'At least 8 characters',
              newPassword: true,
              validator: validateNewPassword,
              onSubmitted: _save,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            FormErrorText(_error!),
          ],
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: _busy ? null : _save,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: const Text('Change password'),
          ),
        ],
      ),
    );
  }
}
