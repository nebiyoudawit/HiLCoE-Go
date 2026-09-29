import 'dart:async';

import '../models/class_slot.dart';
import '../models/course.dart';
import '../models/exam.dart';
import 'local_store.dart';

/// Where a student's courses (with grades and absences), exams and weekly
/// schedule live. Each list is watched as a stream so changes made on
/// another device show up live.
abstract class CourseRepository {
  Stream<List<Course>> watchCourses(String uid);
  Stream<List<Exam>> watchExams(String uid);
  Stream<List<ClassSlot>> watchSchedule(String uid);

  Future<void> saveCourses(String uid, List<Course> courses);
  Future<void> saveExams(String uid, List<Exam> exams);
  Future<void> saveSchedule(String uid, List<ClassSlot> slots);

  /// Brings over data saved on this phone before accounts moved online.
  Future<void> importLocal(String uid, String email) async {}
}

List<Course> decodeCourses(Object? raw) => [
      for (final c in (raw as List? ?? const []))
        Course.fromJson(Map<String, dynamic>.from(c as Map)),
    ];

List<Exam> decodeExams(Object? raw) => [
      for (final e in (raw as List? ?? const []))
        Exam.fromJson(Map<String, dynamic>.from(e as Map)),
    ];

List<ClassSlot> decodeSchedule(Object? raw) => [
      for (final s in (raw as List? ?? const []))
        ClassSlot.fromJson(Map<String, dynamic>.from(s as Map)),
    ];

/// Keeps everything in SharedPreferences on this device. Used by tests,
/// and to read data saved before the app had cloud accounts.
class LocalCourseRepository extends CourseRepository {
  LocalCourseRepository(this._store);

  final LocalStore _store;
  final _controllers = <String, StreamController<Object?>>{};

  static String coursesKey(String id) => 'courses.$id';
  static String examsKey(String id) => 'exams.$id';
  static String scheduleKey(String id) => 'schedule.$id';

  /// Emits the stored value straight away on listen, then after each save.
  Stream<Object?> _watch(String key) {
    final controller = _controllers.putIfAbsent(
      key,
      () => StreamController<Object?>.broadcast(sync: true),
    );
    late final StreamController<Object?> out;
    out = StreamController<Object?>(
      sync: true,
      onListen: () {
        out.add(_store.readJson(key));
        out.addStream(controller.stream);
      },
    );
    return out.stream;
  }

  Future<void> _save(String key, Object value) async {
    await _store.writeJson(key, value);
    _controllers[key]?.add(value);
  }

  bool hasDataFor(String id) =>
      _store.getString(coursesKey(id)) != null ||
      _store.getString(examsKey(id)) != null ||
      _store.getString(scheduleKey(id)) != null;

  Object? read(String key) => _store.readJson(key);

  Future<void> clear(String id) async {
    await _store.remove(coursesKey(id));
    await _store.remove(examsKey(id));
    await _store.remove(scheduleKey(id));
  }

  @override
  Stream<List<Course>> watchCourses(String uid) =>
      _watch(coursesKey(uid)).map(decodeCourses);

  @override
  Stream<List<Exam>> watchExams(String uid) =>
      _watch(examsKey(uid)).map(decodeExams);

  @override
  Stream<List<ClassSlot>> watchSchedule(String uid) =>
      _watch(scheduleKey(uid)).map(decodeSchedule);

  @override
  Future<void> saveCourses(String uid, List<Course> courses) =>
      _save(coursesKey(uid), courses.map((c) => c.toJson()).toList());

  @override
  Future<void> saveExams(String uid, List<Exam> exams) =>
      _save(examsKey(uid), exams.map((e) => e.toJson()).toList());

  @override
  Future<void> saveSchedule(String uid, List<ClassSlot> slots) =>
      _save(scheduleKey(uid), slots.map((s) => s.toJson()).toList());
}
