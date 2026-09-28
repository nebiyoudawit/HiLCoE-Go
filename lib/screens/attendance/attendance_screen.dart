import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/term.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/absence_meter.dart';
import '../../widgets/pill_segments.dart';

/// Absences per course for a term, up to [Course.maxAbsences] each.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final courses = state.coursesFor(term);
    final top = state.mostMissed(term);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 110,
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
            Text('Attendance', style: AppTheme.display(30)),
            const SizedBox(height: 4),
            Text(
              '${term.code} term · up to ${Course.maxAbsences} absences '
              'per course',
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            PillSegments<Term>(
              values: Term.values,
              selected: term,
              labelOf: (t) => t.code,
              onChanged: (t) => context.read<CourseState>().term = t,
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              Text(
                'No ${term.code} courses yet. Add your courses first, then '
                'track absences here.',
                style: const TextStyle(
                    fontSize: 14, height: 1.45, color: AppColors.muted),
              )
            else ...[
              _MostMissedCard(course: top),
              const SizedBox(height: 14),
              const Text(
                'Tap Absent when you miss a class. Tap the minus to undo.',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              for (final course in courses) ...[
                _AttendanceRow(course: course),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MostMissedCard extends StatelessWidget {
  const _MostMissedCard({required this.course});

  /// Null when nothing has been missed this term.
  final Course? course;

  @override
  Widget build(BuildContext context) {
    final c = course;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOST MISSED',
                    style: AppTheme.eyebrow(
                        color: AppColors.onBlueMuted, size: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c?.code ?? 'None yet',
                    style: AppTheme.display(24, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c == null
                        ? 'No absences yet this term'
                        : AbsenceStatus.note(c),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFFE6EDFE)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                text: '${c?.absenceCount ?? 0}',
                children: [
                  TextSpan(
                    text: ' / ${Course.maxAbsences}',
                    style: AppTheme.display(20, color: AppColors.onBlueMuted),
                  ),
                ],
              ),
              style: AppTheme.display(40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final status = AbsenceStatus.of(course);
    final state = context.read<CourseState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: status.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: course.code,
                    children: [
                      TextSpan(
                        text: '  ${course.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: AbsenceDots(course: course)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 60,
                      child: Text(
                        status.label,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: status.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove an absence for ${course.code}',
            onPressed: course.absenceCount == 0
                ? null
                : () => state.removeLastAbsence(course.id),
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.subtle,
          ),
          OutlinedButton(
            onPressed: () => state.addAbsence(course.id),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: AppColors.tint,
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
              shape: const StadiumBorder(),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: const Text('Absent'),
          ),
        ],
      ),
    );
  }
}
