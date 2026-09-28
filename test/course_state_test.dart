import 'package:flutter_test/flutter_test.dart';
import 'package:hilcoe_go/data/course_repository.dart';
import 'package:hilcoe_go/data/local_store.dart';
import 'package:hilcoe_go/models/course.dart';
import 'package:hilcoe_go/models/term.dart';
import 'package:hilcoe_go/state/course_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('academic year labels', () {
    expect(academicStartYear(DateTime(2026, 9, 1)), 2026);
    expect(academicStartYear(DateTime(2027, 8, 31)), 2026);
    expect(yearLabel(2025), '2025–26');
    expect(yearLabel(2099), '2099–00');
  });

  test('courses are split by academic year', () async {
    SharedPreferences.setMockInitialValues({});
    final state = CourseState(CourseRepository(await LocalStore.open()))
      ..setUser('a@example.com');
    final now = state.currentYear;

    Course make(String id, int year) => Course(
          id: id,
          term: Term.aut,
          code: 'CS 201',
          title: 'Data Structures',
          creditHours: 4,
          year: year,
        );
    await state.add(make('this', now));
    await state.add(make('last', now - 1));

    expect(state.coursesFor(Term.aut).map((c) => c.id), ['this']);
    expect(
        state.coursesFor(Term.aut, year: now - 1).map((c) => c.id), ['last']);
    // The same code can be taken again in a different year.
    expect(state.codeTaken(Term.aut, now, 'cs 201'), isTrue);
    expect(state.codeTaken(Term.aut, now - 2, 'cs 201'), isFalse);
    expect(state.pickableYears.first, now);
    expect(state.courseCountIn(now - 1), 1);
  });

  test('old courses without a year join the current one', () {
    final json = const Course(
      id: 'x',
      term: Term.win,
      code: 'MATH 211',
      title: 'Linear Algebra',
      creditHours: 3,
      year: 2020,
    ).toJson()
      ..remove('year');
    expect(Course.fromJson(json).year, academicStartYear());
  });
}
