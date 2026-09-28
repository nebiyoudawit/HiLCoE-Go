import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The rounded segmented switch used for Log in / Sign up and the
/// AUT / WIN / SPR term picker.
class PillSegments<T> extends StatelessWidget {
  const PillSegments({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.background = AppColors.segment,
    this.height = 44,
    this.filled = true,
  });

  /// Filled blue "bubble" for the selected option; false gives the
  /// quieter white pill used on the log in / sign up switch.
  final bool filled;

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: filled ? AppColors.tint : background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(values[i])),
          ],
        ],
      ),
    );
  }

  Widget _segment(T value) {
    final isSelected = value == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: !isSelected
                ? Colors.transparent
                : filled
                    ? AppColors.blue
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: !isSelected
                ? null
                : filled
                    ? const [
                        BoxShadow(
                          color: Color(0x401D4ED8),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x240F172A),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
          ),
          child: Text(
            labelOf(value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: !isSelected
                  ? AppColors.muted
                  : filled
                      ? Colors.white
                      : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
