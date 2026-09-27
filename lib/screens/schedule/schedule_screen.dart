import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_slot.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import 'class_editor.dart';

/// Weekly timetable, Monday to Saturday, filled in by hand.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  /// Opens on today, or Monday on a Sunday.
  int _weekday = DateTime.now().weekday == DateTime.sunday
      ? DateTime.monday
      : DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final hasCourses = state.coursesFor(term).isNotEmpty;
    final classes = state.classesOn(term, _weekday);
    final periods = Period.on(_weekday);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('Schedule', style: AppTheme.display(32)),
          const SizedBox(height: 4),
          Text(
            hasCourses
                ? '${term.code} term · tap a period to fill it in'
                : '${term.code} term',
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          _DayPicker(
            selected: _weekday,
            onChanged: (d) => setState(() => _weekday = d),
          ),
          const SizedBox(height: 14),
          if (!hasCourses)
            Text(
              'Add your ${term.code} courses first, then put them in your '
              'timetable here.',
              style: const TextStyle(
                  fontSize: 14, height: 1.45, color: AppColors.muted),
            )
          else ...[
            for (var i = 0; i < periods.length; i++) ...[
              _PeriodRow(
                period: periods[i],
                slot: classes[i],
                onTap: () => showClassEditor(
                  context,
                  weekday: _weekday,
                  period: i,
                  existing: classes[i],
                ),
              ),
              const SizedBox(height: 8),
              if (i == Period.beforeLunch && periods.length > i + 1)
                const _LunchDivider(),
            ],
            if (_weekday == DateTime.saturday) const _HalfDayNote(),
          ],
        ],
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Monday of this week (next week's, on a Sunday).
    final monday = DateTime(today.year, today.month, today.day)
        .add(Duration(days: DateTime.monday - today.weekday))
        .add(Duration(days: today.weekday == DateTime.sunday ? 7 : 0));

    return Row(
      children: [
        for (var d = DateTime.monday; d <= DateTime.saturday; d++) ...[
          if (d > DateTime.monday) const SizedBox(width: 6),
          Expanded(
            child: _dayButton(monday.add(Duration(days: d - 1)), d),
          ),
        ],
      ],
    );
  }

  Widget _dayButton(DateTime date, int weekday) {
    final isSelected = weekday == selected;
    final fg = isSelected ? Colors.white : AppColors.ink;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.blue : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.blue : AppColors.border,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onChanged(weekday),
          child: SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weekdayCode(date), style: AppTheme.eyebrow(color: fg)),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.slot,
    required this.onTap,
  });

  final Period period;
  final ClassSlot? slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const time = TextStyle(
      fontSize: 12,
      color: AppColors.muted,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(period.label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(clockTime(period.startMinutes), style: time),
                Text(clockTime(period.endMinutes), style: time),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: slot == null
                ? _FreeTile(onTap: onTap)
                : _ClassTile(slot: slot!, onTap: onTap),
          ),
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({required this.slot, required this.onTap});

  final ClassSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final course = context.read<CourseState>().byId(slot.courseId);
    final room = slot.room;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(course?.code ?? '', style: AppTheme.eyebrow()),
                      const SizedBox(height: 2),
                      Text(
                        course?.title ?? '',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (room != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: slot.isLab ? AppColors.surface : AppColors.track,
                      border: Border.all(
                        color: slot.isLab ? AppColors.blue : AppColors.track,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot.isLab ? room : 'Room $room',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: slot.isLab ? AppColors.blue : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeTile extends StatelessWidget {
  const _FreeTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.emptyBorder, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          height: 64,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Free period',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.subtle,
                    ),
                  ),
                ),
                Icon(Icons.add_rounded, color: AppColors.subtle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LunchDivider extends StatelessWidget {
  const _LunchDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.inputBorder)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'LUNCH · 13:00 – 14:00',
              style: AppTheme.eyebrow(color: AppColors.subtle),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.inputBorder)),
        ],
      ),
    );
  }
}

class _HalfDayNote extends StatelessWidget {
  const _HalfDayNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule_rounded, color: AppColors.navy, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Half day. Classes end at 13:00 on Saturdays.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
