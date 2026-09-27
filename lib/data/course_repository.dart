import '../models/class_slot.dart';
import '../models/course.dart';
import '../models/exam.dart';
import 'local_store.dart';

/// Stores each account's courses (with grades and absences), exams and
/// weekly class schedule on the device.
class CourseRepository {
  CourseRepository(this._store);

  final LocalStore _store;

  static String _key(String email) => 'courses.$email';
  static String _examsKey(String email) => 'exams.$email';

  List<Course> load(String email) {
    final raw = _store.readJson(_key(email)) as List<dynamic>?;
    if (raw == null) return [];
    return [for (final c in raw) Course.fromJson(c as Map<String, dynamic>)];
  }

  Future<void> save(String email, List<Course> courses) =>
      _store.writeJson(_key(email), courses.map((c) => c.toJson()).toList());

  List<Exam> loadExams(String email) {
    final raw = _store.readJson(_examsKey(email)) as List<dynamic>?;
    if (raw == null) return [];
    return [for (final e in raw) Exam.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> saveExams(String email, List<Exam> exams) =>
      _store.writeJson(_examsKey(email), exams.map((e) => e.toJson()).toList());

  static String _scheduleKey(String email) => 'schedule.$email';

  List<ClassSlot> loadSchedule(String email) {
    final raw = _store.readJson(_scheduleKey(email)) as List<dynamic>?;
    if (raw == null) return [];
    return [
      for (final s in raw) ClassSlot.fromJson(s as Map<String, dynamic>),
    ];
  }

  Future<void> saveSchedule(String email, List<ClassSlot> slots) => _store
      .writeJson(_scheduleKey(email), slots.map((s) => s.toJson()).toList());
}
