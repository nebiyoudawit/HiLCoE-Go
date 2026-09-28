import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/grading.dart';
import '../../models/term.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/app_header.dart';
import '../../widgets/pill_segments.dart';
import '../../widgets/year_picker.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final year = state.viewYear;
    final courses = state.coursesFor(term, year: year);
    final credits = state.creditHoursFor(term, year: year);
    final gpa = gpaOf(courses);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                AddCourseScreen(initialTerm: term, initialYear: year),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add course'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            const AppHeader(),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Courses',
                          style: AppTheme.display(34, color: AppColors.navy)),
                      const SizedBox(height: 4),
                      YearButton(
                        year: year,
                        onChanged: (y) =>
                            context.read<CourseState>().viewYear = y,
                      ),
                    ],
                  ),
                ),
                const _BooksBadge(),
              ],
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
                      ' · $credits credit hours'
                      '${gpa == null ? '' : ' · GPA ${formatGpa(gpa)}'}',
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
            ' · ${course.percent.round()}% · ${course.letter!.letter}'
        : 'Not started';

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailScreen(courseId: course.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.code,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: course.percent / 100,
                        minHeight: 6,
                        color: AppColors.blue,
                        backgroundColor: AppColors.track,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${course.creditHours} cr hrs',
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: started ? AppColors.navy : AppColors.subtle,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

/// Soft stack-of-books badge beside the Courses title.
class _BooksBadge extends StatelessWidget {
  const _BooksBadge();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0xFFDCE6FC), Color(0x00DCE6FC)],
          ),
        ),
        child: const Icon(Icons.auto_stories_rounded,
            size: 42, color: AppColors.blue),
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
            style:
                TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
