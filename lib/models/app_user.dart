class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.batch,
    this.studentId,
  });

  /// Firebase account id; also the key for the student's data.
  final String uid;
  final String name;
  final String email;

  /// Intake batch, for example DRB2301.
  final String batch;
  final String? studentId;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }

  /// Profile fields stored in `users/{uid}`.
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'batch': batch,
        'studentId': studentId,
      };

  factory AppUser.fromJson(String uid, Map<String, dynamic> json) => AppUser(
        uid: uid,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        batch: json['batch'] as String? ?? '',
        studentId: json['studentId'] as String?,
      );
}
