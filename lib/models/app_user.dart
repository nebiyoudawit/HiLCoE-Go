class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.batch,
    this.studentId,
  });

  final String name;
  final String email;

  /// Intake batch, for example DRB2301.
  final String batch;
  final String? studentId;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'batch': batch,
        if (studentId != null) 'studentId': studentId,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] as String,
        email: json['email'] as String,
        batch: json['batch'] as String,
        studentId: json['studentId'] as String?,
      );
}
