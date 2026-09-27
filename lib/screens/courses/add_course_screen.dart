import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/term.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/ids.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/pill_segments.dart';

/// Adds a course, or edits one when [existing] is given.
class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key, this.initialTerm, this.existing});

  final Term? initialTerm;
  final Course? existing;

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  static const _minCredits = 1;
  static const _maxCredits = 6;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _title;
  late Term _term;
  late int _credits;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _code = TextEditingController(text: c?.code);
    _title = TextEditingController(text: c?.title);
    _term = c?.term ?? widget.initialTerm ?? Term.current();
    _credits = c?.creditHours ?? 3;
  }

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the course code';
    final taken = context
        .read<CourseState>()
        .codeTaken(_term, v, exceptId: widget.existing?.id);
    if (taken) return '${Course.normalizeCode(v)} is already in ${_term.code}';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<CourseState>();
    final code = Course.normalizeCode(_code.text);
    final title = _title.text.trim();
    final existing = widget.existing;
    if (existing == null) {
      await state.add(Course(
        id: newId(),
        term: _term,
        code: code,
        title: title,
        creditHours: _credits,
      ));
      // Show the term the course went into.
      state.term = _term;
    } else {
      await state.update(existing.copyWith(
        term: _term,
        code: code,
        title: title,
        creditHours: _credits,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final course = widget.existing!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${course.code}?'),
        content: const Text(
            'This removes the course and every grade entered for it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    await context.read<CourseState>().remove(course.id);
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 26),
          label: Text(_editing ? 'Back' : 'Courses'),
        ),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete course',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.error,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    Text(
                      _editing ? 'Edit course' : 'Add course',
                      style: AppTheme.display(30),
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Term',
                      child: PillSegments<Term>(
                        values: Term.values,
                        selected: _term,
                        labelOf: (t) => t.code,
                        onChanged: (t) => setState(() => _term = t),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'Course code',
                            child: TextFormField(
                              controller: _code,
                              textCapitalization: TextCapitalization.characters,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              validator: _validateCode,
                              decoration: const InputDecoration(
                                hintText: 'e.g. CS 201',
                                fillColor: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 124,
                          child: LabeledField(
                            label: 'Credit hours',
                            child: _CreditStepper(
                              value: _credits,
                              onChanged: (v) => setState(() => _credits = v),
                              min: _minCredits,
                              max: _maxCredits,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Course title',
                      child: TextFormField(
                        controller: _title,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _save(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter the course title'
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Data Structures',
                          fillColor: AppColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PrimaryButton(
                  label: _editing ? 'Save changes' : 'Save course',
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditStepper extends StatelessWidget {
  const _CreditStepper({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fewer credit hours',
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.blue,
          ),
          SizedBox(
            width: 24,
            child: Semantics(
              liveRegion: true,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            tooltip: 'More credit hours',
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }
}
