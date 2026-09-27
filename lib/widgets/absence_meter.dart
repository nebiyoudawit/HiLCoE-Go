import 'package:flutter/material.dart';

import '../models/course.dart';
import '../theme/app_colors.dart';

/// How close a course is to the absence limit, with matching colors.
class AbsenceStatus {
  const AbsenceStatus._(this.label, this.text, this.fill, this.border);

  factory AbsenceStatus.of(Course course) {
    final left = course.absencesLeft;
    if (left < 0) {
      return AbsenceStatus._('${-left} over', AppColors.dangerText,
          AppColors.danger, AppColors.dangerBorder);
    }
    if (left == 0) {
      return const AbsenceStatus._('Limit', AppColors.dangerText,
          AppColors.danger, AppColors.dangerBorder);
    }
    if (left == 1) {
      return const AbsenceStatus._('1 left', AppColors.warningText,
          AppColors.warning, AppColors.warningBorder);
    }
    return AbsenceStatus._(
        '$left left', AppColors.muted, AppColors.blue, AppColors.border);
  }

  final String label;
  final Color text;
  final Color fill;
  final Color border;

  /// One sentence about the course's standing, for summary cards.
  static String note(Course course) {
    final left = course.absencesLeft;
    if (course.absenceCount == 0) return 'No absences yet this term';
    if (left > 0) {
      return '$left ${left == 1 ? 'absence' : 'absences'} left in this course';
    }
    if (left == 0) return 'No absences left in this course';
    return 'Over the limit. Talk to your instructor.';
  }
}

/// Five bars, one per allowed absence, filled as classes are missed.
class AbsenceDots extends StatelessWidget {
  const AbsenceDots({super.key, required this.course, this.height = 8});

  final Course course;
  final double height;

  @override
  Widget build(BuildContext context) {
    final status = AbsenceStatus.of(course);
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < Course.maxAbsences; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color:
                      i < course.absenceCount ? status.fill : AppColors.track,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
