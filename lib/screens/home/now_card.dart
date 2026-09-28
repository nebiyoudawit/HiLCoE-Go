import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_slot.dart';
import '../../models/course.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';

const _ordinals = ['1ST', '2ND', '3RD', '4TH', '5TH'];

/// Indexes of today's periods that have a class and haven't ended by
/// [minute] (minutes after midnight), in order. The first one is the
/// class running now, or the next to start.
List<int> remainingPeriods(
    Map<int, ClassSlot> classes, int weekday, int minute) {
  final periods = Period.on(weekday);
  return [
    for (var i = 0; i < periods.length; i++)
      if (classes[i] != null && periods[i].endMinutes > minute) i,
  ];
}

/// Blue card with the class happening now, or the next one today.
/// Hidden when there are no more classes today.
class NowCard extends StatefulWidget {
  const NowCard({super.key, this.clock = DateTime.now});

  /// Injectable for tests.
  final DateTime Function() clock;

  @override
  State<NowCard> createState() => _NowCardState();
}

class _NowCardState extends State<NowCard> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // Keep the progress bar and "in N min" current.
    _ticker =
        Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final now = widget.clock();
    final minute = now.hour * 60 + now.minute;
    final periods = Period.on(now.weekday);
    final classes = state.classesOn(state.term, now.weekday);

    final remaining = remainingPeriods(classes, now.weekday, minute);
    if (remaining.isEmpty) return const SizedBox.shrink();

    final first = remaining.first;
    final period = periods[first];
    final slot = classes[first]!;
    final course = state.byId(slot.courseId);
    if (course == null) return const SizedBox.shrink();

    final running = minute >= period.startMinutes;
    final next = remaining.length > 1 ? remaining[1] : null;
    final nextSlot = next == null ? null : classes[next];
    final nextCourse = nextSlot == null ? null : state.byId(nextSlot.courseId);

    final String label;
    if (running) {
      label = 'NOW · ${_ordinals[first]} PERIOD';
    } else {
      final wait = period.startMinutes - minute;
      label = wait <= 60
          ? 'NEXT · IN $wait MIN'
          : 'NEXT · ${_ordinals[first]} PERIOD';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        container: true,
        label: running ? 'Current class' : 'Next class',
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label,
                        style: AppTheme.eyebrow(
                            color: AppColors.onBlueMuted, size: 13)),
                  ),
                  Text(
                    '${clockTime(period.startMinutes)} – '
                    '${clockTime(period.endMinutes)}',
                    style: AppTheme.eyebrow(
                        color: AppColors.onBlueMuted, size: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(course.title,
                  style: AppTheme.display(24, color: Colors.white)),
              const SizedBox(height: 2),
              Text(
                _where(course, slot),
                style: const TextStyle(fontSize: 15, color: Color(0xFFE6EDFE)),
              ),
              if (running) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (minute - period.startMinutes) /
                        (period.endMinutes - period.startMinutes),
                    minHeight: 6,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
              ],
              if (nextCourse != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Then: ${nextCourse.code} at '
                  '${clockTime(periods[next!].startMinutes)}'
                  '${nextSlot!.room == null ? '' : ' in ${nextSlot.room}'}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.onBlueMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _where(Course course, ClassSlot slot) {
    final room = slot.room;
    if (room == null) return course.code;
    return '${course.code} · ${slot.isLab ? room : 'Room $room'}';
  }
}
