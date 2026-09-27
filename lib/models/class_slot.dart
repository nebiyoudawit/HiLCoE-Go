/// One of HiLCoE's daily class periods.
class Period {
  const Period(this.label, this.startMinutes, this.endMinutes);

  final String label;

  /// Minutes after midnight.
  final int startMinutes;
  final int endMinutes;

  /// Periods run Monday to Friday; Saturday is a half day with the first
  /// three. Lunch is 13:00 to 14:00, between the 3rd and 4th.
  static const all = [
    Period('1st', 480, 570), // 8:00 – 9:30
    Period('2nd', 585, 675), // 9:45 – 11:15
    Period('3rd', 690, 780), // 11:30 – 13:00
    Period('4th', 840, 930), // 14:00 – 15:30
    Period('5th', 945, 1020), // 15:45 – 17:00
  ];

  static const saturdayCount = 3;

  /// Index of the last period before lunch.
  static const beforeLunch = 2;

  /// Periods held on [weekday] (DateTime.monday..saturday).
  static List<Period> on(int weekday) {
    if (weekday == DateTime.saturday) return all.sublist(0, saturdayCount);
    if (weekday == DateTime.sunday) return const [];
    return all;
  }
}

/// A course meeting in one period of the week, e.g. CS 201 on Monday
/// 1st period in room 301.
class ClassSlot {
  const ClassSlot({
    required this.id,
    required this.courseId,
    required this.weekday,
    required this.period,
    this.room,
  });

  final String id;
  final String courseId;

  /// DateTime.monday (1) to DateTime.saturday (6).
  final int weekday;

  /// Index into [Period.all].
  final int period;
  final String? room;

  bool get isLab => room?.toUpperCase().startsWith('LAB') ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'weekday': weekday,
        'period': period,
        if (room != null) 'room': room,
      };

  factory ClassSlot.fromJson(Map<String, dynamic> json) => ClassSlot(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        weekday: json['weekday'] as int,
        period: json['period'] as int,
        room: json['room'] as String?,
      );
}
