import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/grading.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/app_header.dart';
import 'home_tiles.dart';
import 'now_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenCourses,
    required this.onOpenExams,
    required this.onOpenSchedule,
  });

  final VoidCallback onOpenCourses;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final courses = state.coursesFor(term);
    final now = DateTime.now();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const AppHeader(),
          const SizedBox(height: 22),
          Text(
            longDate(now),
            style: const TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Scales down rather than wrapping "Good afternoon".
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(greeting(now),
                            maxLines: 1,
                            style: AppTheme.display(30, color: AppColors.navy)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(_greetingIcon(now), color: AppColors.blue, size: 26),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TermChip(label: '${term.code} term', onTap: onOpenCourses),
            ],
          ),
          const SizedBox(height: 18),
          const NowCard(),
          TodayClasses(onOpenSchedule: onOpenSchedule),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: NextExamTile(onTap: onOpenExams)),
                const SizedBox(width: 12),
                const Expanded(child: AttendanceTile()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _TermSummary(
            termCode: term.code,
            courseCount: courses.length,
            creditHours: state.creditHoursFor(term),
            gpa: gpaOf(courses),
            cgpa: gpaOf(state.all),
            onTap: onOpenCourses,
          ),
          const SizedBox(height: 24),
          const _Tagline(),
        ],
      ),
    );
  }

  static IconData _greetingIcon(DateTime now) {
    if (now.hour < 12) return Icons.wb_sunny_outlined;
    if (now.hour < 17) return Icons.wb_twilight_rounded;
    return Icons.nightlight_outlined;
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tint,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Term size and GPA, tapping through to Courses.
class _TermSummary extends StatelessWidget {
  const _TermSummary({
    required this.termCode,
    required this.courseCount,
    required this.creditHours,
    required this.gpa,
    required this.cgpa,
    required this.onTap,
  });

  final String termCode;
  final int courseCount;
  final int creditHours;

  /// Null until a course in scope has grades.
  final ({double gpa, bool estimated})? gpa;
  final ({double gpa, bool estimated})? cgpa;
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.menu_book_outlined, color: AppColors.blue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$termCode TERM',
                        style: AppTheme.eyebrow(color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                      '${courseCount == 1 ? '1 course' : '$courseCount courses'}'
                      ' · $creditHours cr hrs',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              if (gpa != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      gpa!.estimated ? 'GPA (EST.)' : 'GPA',
                      style: AppTheme.eyebrow(color: AppColors.muted),
                    ),
                    Text(gpa!.gpa.toStringAsFixed(2),
                        style: AppTheme.display(24, color: AppColors.navy)),
                    if (cgpa != null)
                      Text(
                        'CGPA ${cgpa!.gpa.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
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

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        SizedBox(width: 12),
        Text(
          'Track your progress. Stay on top.',
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        SizedBox(width: 6),
        Icon(Icons.school_outlined, size: 16, color: AppColors.blue),
        SizedBox(width: 12),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
