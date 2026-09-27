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
  });

  final String id;
  final Term term;
  final String code;
  final String title;
  final int creditHours;
  final List<Grade> grades;

  /// Running total of marks earned so far.
  double get earned => grades.fold(0, (sum, g) => sum + g.score);

  /// Marks available across the grades entered so far.
  double get counted => grades.fold(0, (sum, g) => sum + g.outOf);

  bool get hasGrades => grades.isNotEmpty && counted > 0;

  /// Percentage of counted marks earned, 0 when nothing is entered.
  double get percent => hasGrades ? earned / counted * 100 : 0;

  Course copyWith({
    Term? term,
    String? code,
    String? title,
    int? creditHours,
    List<Grade>? grades,
  }) {
    return Course(
      id: id,
      term: term ?? this.term,
      code: code ?? this.code,
      title: title ?? this.title,
      creditHours: creditHours ?? this.creditHours,
      grades: grades ?? this.grades,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term.code,
        'code': code,
        'title': title,
        'creditHours': creditHours,
        'grades': grades.map((g) => g.toJson()).toList(),
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
      );

  /// Uppercases and tidies spacing so "cs  201" and "CS 201" match.
  static String normalizeCode(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
}
