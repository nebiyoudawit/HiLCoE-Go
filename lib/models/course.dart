import 'grade.dart';
import 'term.dart';

class Course {
  const Course({
    required this.id,
    required this.term,
    required this.code,
    required this.title,
    required this.creditHours,
    this.grades = const [],
    this.absences = const [],
  });

  /// Most classes a student may miss in one course per term.
  static const maxAbsences = 5;

  final String id;
  final Term term;
  final String code;
  final String title;
  final int creditHours;
  final List<Grade> grades;

  /// The day of each class missed, in the order they were logged.
  final List<DateTime> absences;

  int get absenceCount => absences.length;

  /// Absences still allowed; negative once over the limit.
  int get absencesLeft => maxAbsences - absenceCount;

  /// Running total of marks earned so far.
  double get earned => grades.fold(0, (sum, g) => sum + g.score);

  /// Marks available across the grades entered so far.
  double get counted => grades.fold(0, (sum, g) => sum + g.outOf);

  bool get hasGrades => grades.isNotEmpty && counted > 0;

  /// Grades grouped in assessment order (quizzes first, final last),
  /// keeping the order they were entered within each type.
  List<Grade> get sortedGrades {
    final indexed = grades.indexed.toList()
      ..sort((a, b) {
        final byType = a.$2.type.index.compareTo(b.$2.type.index);
        return byType != 0 ? byType : a.$1.compareTo(b.$1);
      });
    return [for (final (_, g) in indexed) g];
  }

  /// Suggested name for the next grade of [type], e.g. "Quiz 3".
  String nextLabelFor(GradeType type) {
    if (type == GradeType.midExam || type == GradeType.finalExam) {
      return type.label;
    }
    final count = grades.where((g) => g.type == type).length;
    return '${type.label} ${count + 1}';
  }

  /// Percentage of counted marks earned, 0 when nothing is entered.
  double get percent => hasGrades ? earned / counted * 100 : 0;

  Course copyWith({
    Term? term,
    String? code,
    String? title,
    int? creditHours,
    List<Grade>? grades,
    List<DateTime>? absences,
  }) {
    return Course(
      id: id,
      term: term ?? this.term,
      code: code ?? this.code,
      title: title ?? this.title,
      creditHours: creditHours ?? this.creditHours,
      grades: grades ?? this.grades,
      absences: absences ?? this.absences,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term.code,
        'code': code,
        'title': title,
        'creditHours': creditHours,
        'grades': grades.map((g) => g.toJson()).toList(),
        'absences': absences.map((d) => d.toIso8601String()).toList(),
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        term: Term.fromCode(json['term'] as String),
        code: json['code'] as String,
        title: json['title'] as String,
        creditHours: json['creditHours'] as int,
        grades: [
          for (final g in (json['grades'] as List? ?? const []))
            Grade.fromJson(g as Map<String, dynamic>),
        ],
        absences: [
          for (final d in (json['absences'] as List? ?? const []))
            DateTime.parse(d as String),
        ],
      );

  /// Uppercases and tidies spacing so "cs  201" and "CS 201" match.
  static String normalizeCode(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
}
