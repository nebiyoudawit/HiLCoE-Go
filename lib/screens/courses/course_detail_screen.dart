import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/grade.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/absence_meter.dart';
import '../../widgets/form_bits.dart';
import '../attendance/attendance_screen.dart';
import 'add_course_screen.dart';
import 'add_grade_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = context.watch<CourseState>().byId(courseId);
    // The course was deleted while this screen was open.
    if (course == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 26),
          label: const Text('Courses'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddCourseScreen(existing: course),
              ),
            ),
            child: const Text('Edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _body(course)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: PrimaryButton(
                label: 'Add grade',
                icon: Icons.add_rounded,
                onPressed: () => _openGrade(context, course),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openGrade(BuildContext context, Course course, [Grade? grade]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddGradeScreen(course: course, existing: grade),
      ),
    );
  }

  Widget _body(Course course) {
    return Builder(
      builder: (context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            '${course.code} · ${course.term.code} · '
            '${course.creditHours} CREDIT '
            '${course.creditHours == 1 ? 'HOUR' : 'HOURS'}',
            style: AppTheme.eyebrow(size: 13),
          ),
          const SizedBox(height: 4),
          Text(course.title, style: AppTheme.display(30)),
          const SizedBox(height: 16),
          _TotalCard(course: course),
          const SizedBox(height: 12),
          _AttendanceTile(course: course),
          const SizedBox(height: 16),
          const Text(
            'My grades',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (course.grades.isEmpty)
            const Text(
              'No grades entered yet. Add each quiz, assignment, project '
              'and exam as you get it back.',
              style:
                  TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
            )
          else
            _GradeList(
              course: course,
              onTap: (grade) => _openGrade(context, course, grade),
            ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final count = course.grades.length;
    return Container(
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
                  'TOTAL SO FAR',
                  style:
                      AppTheme.eyebrow(color: AppColors.onBlueMuted, size: 13),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: formatMark(course.earned),
                    children: [
                      TextSpan(
                        text: ' / ${formatMark(course.counted)}',
                        style:
                            AppTheme.display(20, color: AppColors.onBlueMuted),
                      ),
                    ],
                  ),
                  style: AppTheme.display(40, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                course.hasGrades ? '${course.percent.round()}%' : '–',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count == 1 ? '1 grade entered' : '$count grades entered',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.onBlueMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final status = AbsenceStatus.of(course);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: status.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<CourseState>().term = course.term;
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AttendanceScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Attendance · ${course.absenceCount} of '
                            '${Course.maxAbsences} absences',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: status.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AbsenceDots(course: course),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeList extends StatelessWidget {
  const _GradeList({required this.course, required this.onTap});

  final Course course;
  final ValueChanged<Grade> onTap;

  @override
  Widget build(BuildContext context) {
    final grades = course.sortedGrades;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < grades.length; i++) ...[
            if (i > 0) const Divider(),
            InkWell(
              onTap: () => onTap(grades[i]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        grades[i].type.label.toUpperCase(),
                        style: AppTheme.eyebrow(color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(grades[i].label,
                              style: const TextStyle(fontSize: 15)),
                          if (grades[i].date != null)
                            Text(
                              shortDate(grades[i].date!),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${formatMark(grades[i].score)} / '
                      '${formatMark(grades[i].outOf)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
