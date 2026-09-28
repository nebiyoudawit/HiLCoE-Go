import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_slot.dart';
import '../../models/exam.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../util/ids.dart';
import '../../widgets/date_button.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/pill_segments.dart';
import '../../widgets/select_chip.dart';

/// Exams usually start when a class period does.
final periodStarts = [for (final p in Period.all) p.startMinutes];

/// Adds an exam for one of this term's courses, or edits [existing].
class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key, this.existing});

  final Exam? existing;

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  late final TextEditingController _room;
  String? _courseId;
  late ExamType _type;
  DateTime? _date;
  late int _start;
  bool _triedSave = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _room = TextEditingController(text: e?.room);
    _courseId = e?.courseId;
    _type = e?.type ?? ExamType.mid;
    _date = e?.date;
    _start = e?.startMinutes ?? periodStarts.first;
  }

  @override
  void dispose() {
    _room.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _start ~/ 60, minute: _start % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _start = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);
    final courseId = _courseId;
    final date = _date;
    if (courseId == null || date == null) return;
    final room = _room.text.trim();
    final exam = Exam(
      id: widget.existing?.id ?? newId(),
      courseId: courseId,
      type: _type,
      date: DateTime(date.year, date.month, date.day),
      startMinutes: _start,
      room: room.isEmpty ? null : room,
    );
    await context.read<CourseState>().saveExam(exam);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this exam?'),
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
    await context.read<CourseState>().removeExam(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final editingCourse =
        _editing ? state.byId(widget.existing!.courseId) : null;
    final courses = state.coursesFor(
      editingCourse?.term ?? state.term,
      year: editingCourse?.year,
    );
    final customTime = !periodStarts.contains(_start);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 110,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 26),
          label: const Text('Exams'),
        ),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete exam',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.error,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Text(
                    _editing ? 'Edit exam' : 'Add exam',
                    style: AppTheme.display(30),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Course',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in courses)
                          SelectChip(
                            label: c.code,
                            selected: c.id == _courseId,
                            onTap: () => setState(() => _courseId = c.id),
                          ),
                      ],
                    ),
                  ),
                  if (_triedSave && _courseId == null)
                    _error('Pick the course'),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Which exam',
                    child: PillSegments<ExamType>(
                      values: const [
                        ExamType.quiz,
                        ExamType.mid,
                        ExamType.finalExam,
                        ExamType.other,
                      ],
                      selected: _type,
                      labelOf: (t) => t.label,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Date',
                    child: DateButton(
                      date: _date,
                      onPick: _pickDate,
                      errorText: _triedSave && _date == null
                          ? 'Pick the exam date'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Start time',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final start in periodStarts)
                          SelectChip(
                            label: clockTime(start),
                            selected: start == _start,
                            onTap: () => setState(() => _start = start),
                          ),
                        SelectChip(
                          label: customTime ? clockTime(_start) : 'Other…',
                          selected: customTime,
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Room',
                    hint: '(optional)',
                    child: TextField(
                      controller: _room,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 401 or LAB 301',
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
                label: _editing ? 'Save changes' : 'Save exam',
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _error(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.error),
        ),
      );
}
