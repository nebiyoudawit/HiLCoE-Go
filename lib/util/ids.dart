import 'dart:math';

final _random = Random();

/// Short unique id for locally stored records.
String newId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final noise = _random.nextInt(1 << 30).toRadixString(36);
  return '$time$noise';
}
