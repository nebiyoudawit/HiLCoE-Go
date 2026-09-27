import 'package:flutter_test/flutter_test.dart';
import 'package:hilcoe_go/models/course.dart';
import 'package:hilcoe_go/models/grade.dart';
import 'package:hilcoe_go/models/term.dart';
import 'package:hilcoe_go/util/validators.dart';

void main() {
  group('Course totals', () {
    test('sums grades into a running total', () {
      const course = Course(
        id: 'c1',
        term: Term.aut,
        code: 'CS 201',
        title: 'Data Structures',
        creditHours: 4,
        grades: [
          Grade(id: 'g1', type: GradeType.quiz, label: 'Quiz 1', score: 4, outOf: 5),
          Grade(id: 'g2', type: GradeType.midExam, label: 'Mid', score: 16, outOf: 20),
        ],
      );
      expect(course.earned, 20);
      expect(course.counted, 25);
      expect(course.percent, 80);
    });

    test('round-trips through JSON', () {
      const course = Course(
        id: 'c1',
        term: Term.win,
        code: 'MATH 211',
        title: 'Linear Algebra',
        creditHours: 3,
      );
      final copy = Course.fromJson(course.toJson());
      expect(copy.term, Term.win);
      expect(copy.code, 'MATH 211');
      expect(copy.grades, isEmpty);
    });

    test('normalizes course codes', () {
      expect(Course.normalizeCode('  cs   201 '), 'CS 201');
    });
  });

  group('Terms', () {
    test('guesses the term from the month', () {
      expect(Term.current(DateTime(2026, 10, 1)), Term.aut);
      expect(Term.current(DateTime(2027, 2, 1)), Term.win);
      expect(Term.current(DateTime(2027, 5, 1)), Term.spr);
    });

    test('labels the academic year', () {
      expect(academicYearLabel(DateTime(2026, 9, 27)), '2026–27');
      expect(academicYearLabel(DateTime(2027, 3, 1)), '2026–27');
    });
  });

  test('batch accepts any non-empty text', () {
    expect(validateBatch('DRB2301'), isNull);
    expect(validateBatch('2301 evening'), isNull);
    expect(validateBatch('  '), isNotNull);
  });
}
