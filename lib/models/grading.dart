import 'course.dart';
import 'grade.dart';

/// One step of HiLCoE's grading scale.
class LetterGrade {
  const LetterGrade(this.letter, this.minPercent, this.points);

  final String letter;

  /// Lowest percentage that earns this letter.
  final double minPercent;
  final double points;

  /// HiLCoE's scale, highest first.
  static const scale = [
    LetterGrade('A+', 90, 4.0),
    LetterGrade('A', 85, 4.0),
    LetterGrade('B+', 75, 3.5),
    LetterGrade('B', 65, 3.0),
    LetterGrade('C+', 60, 2.5),
    LetterGrade('C', 50, 2.0),
    LetterGrade('D', 40, 1.0),
    LetterGrade('F', 0, 0.0),
  ];

  static LetterGrade forPercent(double percent) =>
      scale.firstWhere((g) => percent >= g.minPercent);
}

extension CourseGrading on Course {
  /// Letter for the marks so far, or null before any grade is entered.
  /// Uses the whole-number percent the app shows, so "85%" reads as A.
  LetterGrade? get letter =>
      hasGrades ? LetterGrade.forPercent(percent.roundToDouble()) : null;

  /// The letter is only final once the final exam is in.
  bool get letterIsFinal => grades.any((g) => g.type == GradeType.finalExam);
}

/// Credit-weighted GPA of [courses] that have grades, or null if none do.
/// [estimated] is true when any counted course has no final exam yet.
({double gpa, bool estimated})? gpaOf(Iterable<Course> courses) {
  var points = 0.0;
  var credits = 0;
  var estimated = false;
  for (final c in courses) {
    final letter = c.letter;
    if (letter == null) continue;
    points += letter.points * c.creditHours;
    credits += c.creditHours;
    if (!c.letterIsFinal) estimated = true;
  }
  if (credits == 0) return null;
  return (gpa: points / credits, estimated: estimated);
}
