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

/// Academic year label such as "2026–27"; a new year starts in September.
String academicYearLabel([DateTime? now]) {
  final date = now ?? DateTime.now();
  final start = date.month >= 9 ? date.year : date.year - 1;
  final end = (start + 1) % 100;
  return '$start–${end.toString().padLeft(2, '0')}';
}
