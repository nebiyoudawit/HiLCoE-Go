const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// e.g. "Monday, 28 September".
String longDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

/// e.g. "Mon 26 Oct".
String shortDate(DateTime date) =>
    '${_weekdays[date.weekday - 1].substring(0, 3)} ${date.day} '
    '${_months[date.month - 1].substring(0, 3)}';

/// e.g. "MON".
String weekdayCode(DateTime date) =>
    _weekdays[date.weekday - 1].substring(0, 3).toUpperCase();

/// 24-hour clock time from minutes after midnight, e.g. 585 -> "9:45".
String clockTime(int minutes) =>
    '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

String greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Drops a trailing ".0" so 16.0 shows as 16 and 4.5 stays 4.5.
String formatMark(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}
