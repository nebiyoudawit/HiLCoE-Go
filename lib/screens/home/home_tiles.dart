import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/absence_meter.dart';
import '../attendance/attendance_screen.dart';

/// White tile with a caption, a big figure and detail lines below.
class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.caption,
    required this.figure,
    required this.children,
    required this.onTap,
  });

  final String caption;
  final Widget figure;
  final List<Widget> children;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(caption, style: AppTheme.eyebrow(color: AppColors.navy)),
              const SizedBox(height: 6),
              figure,
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
        caption: 'NEXT EXAM',
        figure: Text('None yet', style: AppTheme.display(22)),
        onTap: onTap,
        children: const [Text('Add exams from the Exams tab', style: _detail)],
      );
    }

    final days = exam.daysFrom(now);
    return _HomeTile(
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
        caption: 'ATTENDANCE',
        figure: Text('0 missed', style: AppTheme.display(22)),
        onTap: open,
        children: const [Text('Tap to log an absence', style: _detail)],
      );
    }

    return _HomeTile(
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
