final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

FormFieldValidatorFn requiredText(String what) =>
    (value) => (value == null || value.trim().isEmpty) ? 'Enter $what' : null;

typedef FormFieldValidatorFn = String? Function(String? value);

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Enter your email';
  if (!_emailPattern.hasMatch(v)) return 'That doesn\'t look like an email';
  return null;
}

String? validateBatch(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Enter your batch' : null;

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Choose a password';
  if (value.length < 8) return 'Use at least 8 characters';
  return null;
}
