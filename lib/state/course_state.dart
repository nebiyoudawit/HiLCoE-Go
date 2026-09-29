import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../models/class_slot.dart';
import '../models/course.dart';
import '../models/exam.dart';
import '../models/grade.dart';
import '../models/term.dart';

class CourseState extends ChangeNotifier {
  CourseState(this._repo)
      : _term = Term.current(),
        _viewYear = academicStartYear();

  final CourseRepository _repo;
  String? _uid;
  final _subs = <StreamSubscription<Object?>>[];

  /// True while subscribing, so a repository that answers straight away
  /// doesn't notify in the middle of a build.
  bool _attaching = false;
  List<Course> _courses = const [];
  List<Exam> _exams = const [];
  List<ClassSlot> _slots = const [];
  Term _term;
  int _viewYear;

  /// The academic year running now. A fresh one starts each September.
  int get currentYear => academicStartYear();

  /// The academic year the Courses tab is showing; other tabs always use
  /// [currentYear].
  int get viewYear => _viewYear;

  set viewYear(int value) {
    if (value == _viewYear) return;
    _viewYear = value;
    notifyListeners();
  }

  /// Years to offer in the year picker: this year, the five before it,
  /// and any other year that has courses, newest first.
  List<int> get pickableYears {
    final years = {
      for (var y = currentYear; y > currentYear - 6; y--) y,
      for (final c in _courses) c.year,
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  int courseCountIn(int year) => _courses.where((c) => c.year == year).length;

  /// The term the Courses tab is showing.
  Term get term => _term;

  set term(Term value) {
    if (value == _term) return;
    _term = value;
    notifyListeners();
  }

  List<Course> get all => List.unmodifiable(_courses);

  /// Switches to another account's data and keeps it in sync. Called
  /// while providers rebuild, so it doesn't notify itself; the screens
  /// above it rebuild anyway.
  void setUser(String? uid, {String? email}) {
    if (uid == _uid) return;
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _uid = uid;
    _courses = const [];
    _exams = const [];
    _slots = const [];
    if (uid == null) return;

    void changed() {
      if (!_attaching) notifyListeners();
    }

    // Errors (e.g. "permission denied" in the moment between signing out
    // and these listeners being cancelled) are ignored; the next sign-in
    // subscribes afresh.
    void ignore(Object _) {}

    _attaching = true;
    _subs
      ..add(_repo.watchCourses(uid).listen((v) {
        _courses = v;
        changed();
      }, onError: ignore))
      ..add(_repo.watchExams(uid).listen((v) {
        _exams = v;
        changed();
      }, onError: ignore))
      ..add(_repo.watchSchedule(uid).listen((v) {
        _slots = v;
        changed();
      }, onError: ignore));
    _attaching = false;
    if (email != null) _repo.importLocal(uid, email);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  /// Courses in [term] of [year], which defaults to the current year.
  List<Course> coursesFor(Term term, {int? year}) {
    final y = year ?? currentYear;
    return _courses.where((c) => c.term == term && c.year == y).toList();
  }

  int creditHoursFor(Term term, {int? year}) =>
      coursesFor(term, year: year).fold(0, (sum, c) => sum + c.creditHours);

  Course? byId(String id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool codeTaken(Term term, int year, String code, {String? exceptId}) {
    final normalized = Course.normalizeCode(code);
    return _courses.any((c) =>
        c.term == term &&
        c.year == year &&
        c.code == normalized &&
        c.id != exceptId);
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

  /// Deletes a course along with its exams and class times.
  Future<void> remove(String id) async {
    if (_exams.any((e) => e.courseId == id)) {
      await _commitExams(_exams.where((e) => e.courseId != id).toList());
    }
    if (_slots.any((s) => s.courseId == id)) {
      await _commitSlots(_slots.where((s) => s.courseId != id).toList());
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

  /// This [term]'s classes on [weekday], keyed by period index.
  Map<int, ClassSlot> classesOn(Term term, int weekday) {
    final ids = {for (final c in coursesFor(term)) c.id};
    return {
      for (final s in _slots)
        if (s.weekday == weekday && ids.contains(s.courseId)) s.period: s,
    };
  }

  /// Puts [slot] in its period, replacing whatever this term had there.
  Future<void> saveClass(ClassSlot slot) {
    final course = byId(slot.courseId);
    if (course == null) return Future.value();
    final taken = classesOn(course.term, slot.weekday)[slot.period];
    return _commitSlots([
      for (final s in _slots)
        if (s.id != slot.id && s.id != taken?.id) s,
      slot,
    ]);
  }

  Future<void> removeClass(String id) =>
      _commitSlots(_slots.where((s) => s.id != id).toList());

  Future<void> _commitSlots(List<ClassSlot> next) async {
    final uid = _uid;
    if (uid == null) return;
    _slots = next;
    notifyListeners();
    await _repo.saveSchedule(uid, next);
  }

  Future<void> _commitExams(List<Exam> next) async {
    final uid = _uid;
    if (uid == null) return;
    _exams = next;
    notifyListeners();
    await _repo.saveExams(uid, next);
  }

  Future<void> _commit(List<Course> next) async {
    final uid = _uid;
    if (uid == null) return;
    _courses = next;
    notifyListeners();
    await _repo.saveCourses(uid, next);
  }
}
