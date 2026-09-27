import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/grade.dart';
import '../models/term.dart';

class CourseState extends ChangeNotifier {
  CourseState(this._repo) : _term = Term.current();

  final CourseRepository _repo;
  String? _email;
  List<Course> _courses = const [];
  List<Exam> _exams = const [];
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
    _exams = email == null ? const [] : _repo.loadExams(email);
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
    return _courses
        .any((c) => c.term == term && c.code == normalized && c.id != exceptId);
  }

  Future<void> add(Course course) => _commit([..._courses, course]);

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

  /// Logs a missed class, dated today unless [date] is given.
  Future<void> addAbsence(String courseId, [DateTime? date]) {
    final course = byId(courseId);
    if (course == null) return Future.value();
    return update(course.copyWith(
      absences: [...course.absences, date ?? DateTime.now()],
    ));
  }

  /// Undoes the most recently logged absence.
  Future<void> removeLastAbsence(String courseId) {
    final course = byId(courseId);
    if (course == null || course.absences.isEmpty) return Future.value();
    return update(course.copyWith(
      absences: course.absences.sublist(0, course.absences.length - 1),
    ));
  }

  /// The course with the most absences this [term], or null if none missed.
  Course? mostMissed(Term term) {
    Course? top;
    for (final c in coursesFor(term)) {
      if (c.absenceCount > (top?.absenceCount ?? 0)) top = c;
    }
    return top;
  }

  /// Deletes a course along with its exams.
  Future<void> remove(String id) async {
    if (_exams.any((e) => e.courseId == id)) {
      await _commitExams(_exams.where((e) => e.courseId != id).toList());
    }
    await _commit(_courses.where((c) => c.id != id).toList());
  }

  /// Exams for this [term]'s courses, soonest first.
  List<Exam> examsFor(Term term) {
    final ids = {for (final c in coursesFor(term)) c.id};
    return _exams.where((e) => ids.contains(e.courseId)).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  /// The first exam today or later in any term, or null if none.
  Exam? nextExam(DateTime now) {
    Exam? next;
    for (final e in _exams) {
      if (e.daysFrom(now) < 0 || byId(e.courseId) == null) continue;
      if (next == null || e.startsAt.isBefore(next.startsAt)) next = e;
    }
    return next;
  }

  Exam? examById(String id) {
    for (final e in _exams) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Adds [exam], or replaces the exam with the same id.
  Future<void> saveExam(Exam exam) {
    final exists = _exams.any((e) => e.id == exam.id);
    return _commitExams(exists
        ? [for (final e in _exams) e.id == exam.id ? exam : e]
        : [..._exams, exam]);
  }

  Future<void> removeExam(String id) =>
      _commitExams(_exams.where((e) => e.id != id).toList());

  Future<void> _commitExams(List<Exam> next) async {
    final email = _email;
    if (email == null) return;
    _exams = next;
    notifyListeners();
    await _repo.saveExams(email, next);
  }

  Future<void> _commit(List<Course> next) async {
    final email = _email;
    if (email == null) return;
    _courses = next;
    notifyListeners();
    await _repo.save(email, next);
  }
}
