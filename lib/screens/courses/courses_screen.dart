import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/term.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/pill_segments.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final courses = state.coursesFor(term);
    final credits = state.creditHoursFor(term);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddCourseScreen(initialTerm: term),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add course'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
          children: [
            Text('Courses', style: AppTheme.display(32)),
            const SizedBox(height: 4),
            Text(
              '${academicYearLabel()} academic year',
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            PillSegments<Term>(
              values: Term.values,
              selected: term,
              labelOf: (t) => t.code,
              onChanged: (t) => context.read<CourseState>().term = t,
            ),
            const SizedBox(height: 14),
            Text(
              courses.isEmpty
                  ? '${term.longName} term'
                  : '${courses.length} '
                      '${courses.length == 1 ? 'course' : 'courses'}'
                      ' · $credits credit hours',
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            if (courses.isEmpty)
              _EmptyTerm(termCode: term.code)
            else
              for (final course in courses) ...[
                CourseCard(course: course),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final started = course.hasGrades;
    final status = started
        ? '${formatMark(course.earned)}/${formatMark(course.counted)}'
            ' · ${course.percent.round()}%'
        : 'Not started';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailScreen(courseId: course.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.code, style: AppTheme.eyebrow()),
                        const SizedBox(height: 2),
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${course.creditHours} cr hrs',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: course.percent / 100,
                        minHeight: 6,
                        color: AppColors.blue,
                        backgroundColor: AppColors.track,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 116,
                    child: Text(
                      status,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: started ? AppColors.ink : AppColors.subtle,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTerm extends StatelessWidget {
  const _EmptyTerm({required this.termCode});

  final String termCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.emptyBorder, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'No $termCode courses yet',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add the courses you register for this term. You can copy the '
            'code, title and credit hours from your registration slip.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
