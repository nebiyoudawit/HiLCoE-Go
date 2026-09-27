enum ExamType {
  mid('Mid'),
  finalExam('Final'),
  quiz('Quiz'),
  other('Other');

  const ExamType(this.label);

  final String label;
}

/// A scheduled exam for one course.
class Exam {
  const Exam({
    required this.id,
    required this.courseId,
    required this.type,
    required this.date,
    required this.startMinutes,
    this.room,
  });

  final String id;
  final String courseId;
  final ExamType type;

  /// The exam day, with no time part.
  final DateTime date;

  /// Start time as minutes after midnight, e.g. 585 for 9:45.
  final int startMinutes;
  final String? room;

  DateTime get startsAt => date.add(Duration(minutes: startMinutes));

  /// Whole days from [now]'s date to the exam day; 0 on the day itself.
  int daysFrom(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return date.difference(today).inDays;
  }

  Exam copyWith({
    String? courseId,
    ExamType? type,
    DateTime? date,
    int? startMinutes,
    String? room,
  }) {
    return Exam(
      id: id,
      courseId: courseId ?? this.courseId,
      type: type ?? this.type,
      date: date ?? this.date,
      startMinutes: startMinutes ?? this.startMinutes,
      room: room ?? this.room,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'type': type.name,
        'date': date.toIso8601String(),
        'startMinutes': startMinutes,
        if (room != null) 'room': room,
      };

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        type: ExamType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
        startMinutes: json['startMinutes'] as int,
        room: json['room'] as String?,
      );
}
