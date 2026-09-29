import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/class_slot.dart';
import '../models/course.dart';
import '../models/exam.dart';
import 'course_repository.dart';

/// Stores each student's data in Firestore under `users/{uid}/data/`,
/// one document per list (courses, exams, schedule). Firestore caches
/// on the phone, so the app keeps working offline and syncs later.
class FirestoreCourseRepository extends CourseRepository {
  FirestoreCourseRepository(this._db, this._local);

  final FirebaseFirestore _db;

  /// Data saved on this phone before accounts moved online.
  final LocalCourseRepository _local;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String name) =>
      _db.collection('users').doc(uid).collection('data').doc(name);

  Future<void> _save(String uid, String name, List<Object> items) =>
      _doc(uid, name).set({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Stream<List<Course>> watchCourses(String uid) => _doc(uid, 'courses')
      .snapshots()
      .map((s) => decodeCourses(s.data()?['items']));

  @override
  Stream<List<Exam>> watchExams(String uid) => _doc(uid, 'exams')
      .snapshots()
      .map((s) => decodeExams(s.data()?['items']));

  @override
  Stream<List<ClassSlot>> watchSchedule(String uid) => _doc(uid, 'schedule')
      .snapshots()
      .map((s) => decodeSchedule(s.data()?['items']));

  @override
  Future<void> saveCourses(String uid, List<Course> courses) =>
      _save(uid, 'courses', courses.map((c) => c.toJson()).toList());

  @override
  Future<void> saveExams(String uid, List<Exam> exams) =>
      _save(uid, 'exams', exams.map((e) => e.toJson()).toList());

  @override
  Future<void> saveSchedule(String uid, List<ClassSlot> slots) =>
      _save(uid, 'schedule', slots.map((s) => s.toJson()).toList());

  /// Uploads courses, exams and schedule saved on this phone under the
  /// same email, but only into an account that has nothing in the cloud
  /// yet, so it never overwrites synced data. Local copies are removed
  /// once uploaded.
  @override
  Future<void> importLocal(String uid, String email) async {
    if (!_local.hasDataFor(email)) return;
    final cloud = await _doc(uid, 'courses').get();
    if (cloud.exists) return;

    final courses =
        decodeCourses(_local.read(LocalCourseRepository.coursesKey(email)));
    final exams =
        decodeExams(_local.read(LocalCourseRepository.examsKey(email)));
    final slots =
        decodeSchedule(_local.read(LocalCourseRepository.scheduleKey(email)));
    await saveCourses(uid, courses);
    await saveExams(uid, exams);
    await saveSchedule(uid, slots);
    await _local.clear(email);
  }
}
