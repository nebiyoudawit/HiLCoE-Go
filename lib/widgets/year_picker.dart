import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/term.dart';
import '../state/course_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Tappable "2026–27 academic year ▾" that opens the year list.
class YearButton extends StatelessWidget {
  const YearButton({
    super.key,
    required this.year,
    required this.onChanged,
    this.suffix = ' academic year',
    this.boxed = false,
  });

  final int year;
  final ValueChanged<int> onChanged;
  final String suffix;

  /// Input-style box (for forms) instead of inline text.
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final current = context.select<CourseState, int>((s) => s.currentYear);
    final label = '${yearLabel(year)}$suffix'
        '${year == current ? '' : ' · past'}';

    Future<void> pick() async {
      final picked = await showYearPicker(context, selected: year);
      if (picked != null) onChanged(picked);
    }

    if (boxed) {
      return Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
        child: InkWell(
          onTap: pick,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.school_outlined,
                    size: 20, color: AppColors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 16)),
                ),
                const Icon(Icons.expand_more_rounded, color: AppColors.muted),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: 'Academic year $label, change',
      child: InkWell(
        onTap: pick,
        borderRadius: BorderRadius.circular(8),
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 15, color: AppColors.muted)),
                const Icon(Icons.expand_more_rounded,
                    size: 20, color: AppColors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet listing academic years, newest first, with how many
/// courses each has. Returns the picked year, or null if dismissed.
Future<int?> showYearPicker(BuildContext context, {required int selected}) {
  final state = context.read<CourseState>();
  final years = state.pickableYears;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Academic year', style: AppTheme.display(24)),
            const SizedBox(height: 4),
            const Text(
              'Pick a past year to add or review its courses. A new year '
              'starts each September.',
              style: TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            for (final y in years)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                selected: y == selected,
                selectedTileColor: AppColors.tint,
                title: Text(
                  yearLabel(y),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_subtitle(state, y)),
                trailing: y == selected
                    ? const Icon(Icons.check_rounded, color: AppColors.blue)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(y),
              ),
          ],
        ),
      ),
    ),
  );
}

String _subtitle(CourseState state, int year) {
  final count = state.courseCountIn(year);
  final courses = count == 0
      ? 'No courses'
      : count == 1
          ? '1 course'
          : '$count courses';
  return year == state.currentYear ? 'This year · $courses' : courses;
}
