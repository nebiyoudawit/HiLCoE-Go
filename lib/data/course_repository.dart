import '../models/course.dart';
import 'local_store.dart';

/// Stores each account's courses (with their grades) on the device.
class CourseRepository {
  CourseRepository(this._store);

  final LocalStore _store;

  static String _key(String email) => 'courses.$email';

  List<Course> load(String email) {
    final raw = _store.readJson(_key(email)) as List<dynamic>?;
    if (raw == null) return [];
    return [for (final c in raw) Course.fromJson(c as Map<String, dynamic>)];
  }

  Future<void> save(String email, List<Course> courses) => _store.writeJson(
      _key(email), courses.map((c) => c.toJson()).toList());
}
