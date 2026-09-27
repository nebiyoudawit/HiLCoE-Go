import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/grade.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../util/ids.dart';
import '../../widgets/date_button.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/select_chip.dart';

/// Enters one grade, e.g. Mid exam 16 / 20, or edits [existing].
class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({super.key, required this.course, this.existing});

  final Course course;
  final Grade? existing;

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _score;
  late final TextEditingController _outOf;
  late GradeType _type;
  DateTime? _date;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _type = g?.type ?? GradeType.quiz;
    _name = TextEditingController(text: g?.label);
    _score = TextEditingController(text: g == null ? '' : formatMark(g.score));
    _outOf = TextEditingController(text: g == null ? '' : formatMark(g.outOf));
    _date = g?.date;
  }

  @override
  void dispose() {
    _name.dispose();
    _score.dispose();
    _outOf.dispose();
    super.dispose();
  }

  static double? _parse(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', '.'));

  String? _validateOutOf(String? value) {
    final outOf = _parse(value);
    if (outOf == null) return 'Enter a number';
    if (outOf <= 0) return 'Must be more than 0';
    return null;
  }

  String? _validateScore(String? value) {
    final score = _parse(value);
    if (score == null) return 'Enter a number';
    if (score < 0) return 'Can\'t be negative';
    final outOf = _parse(_outOf.text);
    if (outOf != null && score > outOf) {
      return 'Can\'t be over ${formatMark(outOf)}';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final grade = Grade(
      id: widget.existing?.id ?? newId(),
      type: _type,
      label: name.isEmpty ? widget.course.nextLabelFor(_type) : name,
      score: _parse(_score.text)!,
      outOf: _parse(_outOf.text)!,
      date: _date,
    );
    await context.read<CourseState>().saveGrade(widget.course.id, grade);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final grade = widget.existing!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${grade.label}?'),
        content: const Text('It will be taken out of your running total.'),
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
    await context.read<CourseState>().removeGrade(widget.course.id, grade.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));
    const numberStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 140,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 26),
          label: Text(widget.course.code, overflow: TextOverflow.ellipsis),
        ),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete grade',
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
                      _editing ? 'Edit grade' : 'Add grade',
                      style: AppTheme.display(30),
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'What was it?',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final type in GradeType.values)
                            SelectChip(
                              label: type.label,
                              selected: type == _type,
                              onTap: () => setState(() => _type = type),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Name',
                      hint: '(optional)',
                      child: TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: widget.course.nextLabelFor(_type),
                          fillColor: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'My grade',
                            child: TextFormField(
                              controller: _score,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [numberFormatter],
                              textInputAction: TextInputAction.next,
                              validator: _validateScore,
                              style: numberStyle,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 16',
                                fillColor: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(12, 36, 12, 0),
                          child: Text(
                            '/',
                            style:
                                TextStyle(fontSize: 22, color: AppColors.muted),
                          ),
                        ),
                        Expanded(
                          child: LabeledField(
                            label: 'Out of',
                            child: TextFormField(
                              controller: _outOf,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [numberFormatter],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _save(),
                              validator: _validateOutOf,
                              style: numberStyle,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 20',
                                fillColor: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Date',
                      hint: '(optional)',
                      child: DateButton(
                        date: _date,
                        onPick: _pickDate,
                        onClear: () => setState(() => _date = null),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PrimaryButton(
                  label: _editing ? 'Save changes' : 'Save grade',
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
