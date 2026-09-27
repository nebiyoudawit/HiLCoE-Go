import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_slot.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../util/ids.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/select_chip.dart';

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

/// Bottom sheet to put a course in one period, or change/clear it.
Future<void> showClassEditor(
  BuildContext context, {
  required int weekday,
  required int period,
  ClassSlot? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _ClassEditor(
      weekday: weekday,
      period: period,
      existing: existing,
    ),
  );
}

class _ClassEditor extends StatefulWidget {
  const _ClassEditor({
    required this.weekday,
    required this.period,
    this.existing,
  });

  final int weekday;
  final int period;
  final ClassSlot? existing;

  @override
  State<_ClassEditor> createState() => _ClassEditorState();
}

class _ClassEditorState extends State<_ClassEditor> {
  late final TextEditingController _room;
  String? _courseId;
  bool _triedSave = false;

  @override
  void initState() {
    super.initState();
    _courseId = widget.existing?.courseId;
    _room = TextEditingController(text: widget.existing?.room);
  }

  @override
  void dispose() {
    _room.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);
    final courseId = _courseId;
    if (courseId == null) return;
    final room = _room.text.trim();
    await context.read<CourseState>().saveClass(ClassSlot(
          id: widget.existing?.id ?? newId(),
          courseId: courseId,
          weekday: widget.weekday,
          period: widget.period,
          room: room.isEmpty ? null : room.toUpperCase(),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    await context.read<CourseState>().removeClass(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final courses = state.coursesFor(state.term);
    final period = Period.all[widget.period];

    return Padding(
      // Keeps the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_dayNames[widget.weekday - 1]} · ${period.label} period',
                style: AppTheme.display(24),
              ),
              const SizedBox(height: 4),
              Text(
                '${clockTime(period.startMinutes)} – '
                '${clockTime(period.endMinutes)}',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
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
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    'Pick the course',
                    style: TextStyle(fontSize: 12, color: AppColors.error),
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
                  onSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 301 or LAB 201',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Save', onPressed: _save),
              if (widget.existing != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clear,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Make this a free period'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
