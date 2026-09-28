import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_slot.dart';
import '../../models/course.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/absence_meter.dart';
import '../../widgets/app_header.dart';
import '../attendance/attendance_screen.dart';

/// White tile with a caption, a big figure and detail lines below.
class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.caption,
    required this.figure,
    required this.children,
    required this.onTap,
    this.chevron = false,
  });

  final IconData icon;
  final bool chevron;
  final String caption;
  final Widget figure;
  final List<Widget> children;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(caption,
                        style: AppTheme.eyebrow(color: AppColors.muted)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: figure),
                  if (chevron)
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.blue),
                ],
              ),
              const SizedBox(height: 6),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

const _detail = TextStyle(fontSize: 13, color: AppColors.muted);
const _strong = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

class NextExamTile extends StatelessWidget {
  const NextExamTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final now = DateTime.now();
    final exam = state.nextExam(now);
    final course = exam == null ? null : state.byId(exam.courseId);

    if (exam == null || course == null) {
      return _HomeTile(
        icon: Icons.event_note_outlined,
        caption: 'NEXT EXAM',
        figure: Text('None yet', style: AppTheme.display(22)),
        onTap: onTap,
        children: const [Text('Add exams from the Exams tab', style: _detail)],
      );
    }

    final days = exam.daysFrom(now);
    return _HomeTile(
      icon: Icons.event_note_outlined,
      chevron: true,
      caption: 'NEXT EXAM',
      figure: Text(
        switch (days) {
          0 => 'Today',
          1 => 'Tomorrow',
          _ => '$days days',
        },
        style: AppTheme.display(26),
      ),
      onTap: onTap,
      children: [
        Text('${course.code} ${exam.type.label}', style: _strong),
        const SizedBox(height: 2),
        Text(
          '${shortDate(exam.date)} · ${clockTime(exam.startMinutes)}',
          style: _detail,
        ),
      ],
    );
  }
}

/// Today's periods with the class in each, highlighting the one running
/// now. Classes already over are struck through.
class TodayClasses extends StatelessWidget {
  const TodayClasses({super.key, required this.onOpenSchedule});

  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;
    final periods = Period.on(now.weekday);
    final classes = state.classesOn(state.term, now.weekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          icon: Icons.calendar_month_outlined,
          title: 'Today\'s classes',
          action: TextButton(
            onPressed: onOpenSchedule,
            child: const Text('Full week'),
          ),
        ),
        const SizedBox(height: 4),
        if (periods.isEmpty)
          const Text('No classes on Sundays.', style: _detail)
        else if (classes.isEmpty)
          const Text(
            'Nothing scheduled today. Fill in your timetable from the '
            'Schedule tab.',
            style:
                TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Column(
                children: [
                  for (var i = 0; i < periods.length; i++) ...[
                    if (i > 0) const Divider(),
                    _TodayRow(
                      period: periods[i],
                      slot: classes[i],
                      now: minute,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.period,
    required this.slot,
    required this.now,
  });

  final Period period;
  final ClassSlot? slot;

  /// Minutes after midnight right now.
  final int now;

  @override
  Widget build(BuildContext context) {
    final course =
        slot == null ? null : context.read<CourseState>().byId(slot!.courseId);
    final current = now >= period.startMinutes && now < period.endMinutes;
    final over = now >= period.endMinutes;
    final color = current
        ? AppColors.blue
        : over
            ? AppColors.subtle
            : AppColors.muted;

    return Container(
      color: current ? AppColors.tint : null,
      padding: const EdgeInsets.fromLTRB(10, 14, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: current
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          SizedBox(
            width: 96,
            child: Text(
              '${clockTime(period.startMinutes)} – '
              '${clockTime(period.endMinutes)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: course == null
                ? const Text(
                    'Free period',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.subtle,
                    ),
                  )
                : Text(
                    '${course.code} ${course.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                      color: over ? AppColors.subtle : AppColors.ink,
                      decoration: over ? TextDecoration.lineThrough : null,
                    ),
                  ),
          ),
          if (slot?.room != null) ...[
            const SizedBox(width: 8),
            Text(
              slot!.room!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AttendanceTile extends StatelessWidget {
  const AttendanceTile({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final course = state.mostMissed(state.term);

    void open() => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AttendanceScreen()),
        );

    if (course == null) {
      return _HomeTile(
        icon: Icons.bar_chart_rounded,
        caption: 'ATTENDANCE',
        figure: Text('0 missed', style: AppTheme.display(22)),
        onTap: open,
        children: const [Text('Tap to log an absence', style: _detail)],
      );
    }

    return _HomeTile(
      icon: Icons.bar_chart_rounded,
      caption: 'MOST ABSENCES',
      figure: Text.rich(
        TextSpan(
          text: '${course.absenceCount}',
          children: const [
            TextSpan(
              text: ' of ${Course.maxAbsences}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        style: AppTheme.display(26),
      ),
      onTap: open,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AbsenceDots(course: course),
        ),
        const SizedBox(height: 2),
        Text(
          '${course.code} · ${AbsenceStatus.of(course).label}',
          style: _detail,
        ),
      ],
    );
  }
}
