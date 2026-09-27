import 'package:flutter_test/flutter_test.dart';
import 'package:hilcoe_go/models/class_slot.dart';
import 'package:hilcoe_go/models/course.dart';
import 'package:hilcoe_go/models/exam.dart';
import 'package:hilcoe_go/util/format.dart';
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
          Grade(
              id: 'g1',
              type: GradeType.quiz,
              label: 'Quiz 1',
              score: 4,
              outOf: 5),
          Grade(
              id: 'g2',
              type: GradeType.midExam,
              label: 'Mid',
              score: 16,
              outOf: 20),
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

    test('orders grades by type and suggests the next name', () {
      final course = Course(
        id: 'c1',
        term: Term.aut,
        code: 'CS 201',
        title: 'Data Structures',
        creditHours: 4,
        grades: [
          const Grade(
              id: 'm',
              type: GradeType.midExam,
              label: 'Mid exam',
              score: 16,
              outOf: 20),
          Grade(
              id: 'q1',
              type: GradeType.quiz,
              label: 'Quiz 1',
              score: 4,
              outOf: 5,
              date: DateTime(2026, 10, 5)),
          const Grade(
              id: 'q2',
              type: GradeType.quiz,
              label: 'Quiz 2',
              score: 3,
              outOf: 5),
        ],
      );
      expect(course.sortedGrades.map((g) => g.id), ['q1', 'q2', 'm']);
      expect(course.nextLabelFor(GradeType.quiz), 'Quiz 3');
      expect(course.nextLabelFor(GradeType.finalExam), 'Final exam');
      final copy = Course.fromJson(course.toJson());
      expect(copy.grades[1].date, DateTime(2026, 10, 5));
      expect(copy.grades[0].date, isNull);
    });

    test('counts absences against the limit of 5', () {
      final course = Course(
        id: 'c1',
        term: Term.aut,
        code: 'CS 221',
        title: 'Computer Organization',
        creditHours: 3,
        absences: [for (var d = 1; d <= 6; d++) DateTime(2026, 10, d)],
      );
      expect(course.absenceCount, 6);
      expect(course.absencesLeft, -1);
      final copy = Course.fromJson(course.toJson());
      expect(copy.absences.last, DateTime(2026, 10, 6));
      // Courses saved before attendance existed still load.
      final old = course.toJson()..remove('absences');
      expect(Course.fromJson(old).absences, isEmpty);
    });

    test('normalizes course codes', () {
      expect(Course.normalizeCode('  cs   201 '), 'CS 201');
    });
  });

  test('exam start time, countdown and JSON', () {
    final exam = Exam(
      id: 'e1',
      courseId: 'c1',
      type: ExamType.mid,
      date: DateTime(2026, 10, 26),
      startMinutes: 585,
      room: '401',
    );
    expect(exam.startsAt, DateTime(2026, 10, 26, 9, 45));
    expect(exam.daysFrom(DateTime(2026, 9, 28, 23, 59)), 28);
    expect(exam.daysFrom(DateTime(2026, 10, 26, 18)), 0);
    expect(clockTime(exam.startMinutes), '9:45');
    final copy = Exam.fromJson(exam.toJson());
    expect(copy.type, ExamType.mid);
    expect(copy.room, '401');
  });

  test('periods: five on weekdays, three on Saturday, none on Sunday', () {
    expect(Period.on(DateTime.monday).length, 5);
    expect(Period.on(DateTime.saturday).last.endMinutes, 780); // 13:00
    expect(Period.on(DateTime.sunday), isEmpty);
    const slot = ClassSlot(
        id: 's1', courseId: 'c1', weekday: 1, period: 3, room: 'LAB 201');
    expect(slot.isLab, isTrue);
    expect(ClassSlot.fromJson(slot.toJson()).period, 3);
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
