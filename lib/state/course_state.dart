import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../models/course.dart';
import '../models/grade.dart';
import '../models/term.dart';

class CourseState extends ChangeNotifier {
  CourseState(this._repo) : _term = Term.current();

  final CourseRepository _repo;
  String? _email;
  List<Course> _courses = const [];
  Term _term;

  /// The term the Courses tab is showing.
  Term get term => _term;

  set term(Term value) {
    if (value == _term) return;
    _term = value;
    notifyListeners();
  }

  List<Course> get all => List.unmodifiable(_courses);

  /// Switches to another account's data. Called while providers rebuild,
  /// so it doesn't notify; the screens above it rebuild anyway.
  void setUser(String? email) {
    if (email == _email) return;
    _email = email;
    _courses = email == null ? const [] : _repo.load(email);
  }

  List<Course> coursesFor(Term term) =>
      _courses.where((c) => c.term == term).toList();

  int creditHoursFor(Term term) =>
      coursesFor(term).fold(0, (sum, c) => sum + c.creditHours);

  Course? byId(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool codeTaken(Term term, String code, {String? exceptId}) {
    final normalized = Course.normalizeCode(code);
    return _courses.any(
        (c) => c.term == term && c.code == normalized && c.id != exceptId);
  }

  Future<void> add(Course course) =>
      _commit([..._courses, course]);

  Future<void> update(Course course) =>
      _commit([for (final c in _courses) c.id == course.id ? course : c]);

  /// Adds [grade] to the course, or replaces the grade with the same id.
  Future<void> saveGrade(String courseId, Grade grade) {
    final course = byId(courseId);
    if (course == null) return Future.value();
    final exists = course.grades.any((g) => g.id == grade.id);
    return update(course.copyWith(
      grades: exists
          ? [for (final g in course.grades) g.id == grade.id ? grade : g]
          : [...course.grades, grade],
    ));
  }

  Future<void> removeGrade(String courseId, String gradeId) {
    final course = byId(courseId);
    if (course == null) return Future.value();
    return update(course.copyWith(
      grades: course.grades.where((g) => g.id != gradeId).toList(),
    ));
  }

  Future<void> remove(String id) =>
      _commit(_courses.where((c) => c.id != id).toList());

  Future<void> _commit(List<Course> next) async {
    final email = _email;
    if (email == null) return;
    _courses = next;
    notifyListeners();
    await _repo.save(email, next);
  }
}
