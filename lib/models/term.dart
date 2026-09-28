/// HiLCoE's three terms per academic year.
enum Term {
  aut('Autumn'),
  win('Winter'),
  spr('Spring');

  const Term(this.longName);

  final String longName;

  /// Short code shown in the app, e.g. AUT.
  String get code => name.toUpperCase();

  static Term fromCode(String code) =>
      Term.values.firstWhere((t) => t.code == code.toUpperCase());

  /// Best guess at the running term from the calendar month.
  static Term current([DateTime? now]) {
    final month = (now ?? DateTime.now()).month;
    if (month >= 9) return Term.aut;
    if (month <= 3) return Term.win;
    return Term.spr;
  }
}

/// Calendar year an academic year starts in; a new one starts each
/// September, e.g. 2026 for the 2026–27 year.
int academicStartYear([DateTime? now]) {
  final date = now ?? DateTime.now();
  return date.month >= 9 ? date.year : date.year - 1;
}

/// Label such as "2026–27" for the year starting in [start].
String yearLabel(int start) =>
    '$start–${((start + 1) % 100).toString().padLeft(2, '0')}';

/// Label for the academic year running at [now].
String academicYearLabel([DateTime? now]) => yearLabel(academicStartYear(now));
