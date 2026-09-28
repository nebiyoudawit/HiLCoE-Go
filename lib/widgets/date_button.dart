import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../util/format.dart';

/// Input-styled button that opens a date picker, with an optional clear.
class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
    required this.date,
    required this.onPick,
    this.onClear,
    this.errorText,
  });

  final DateTime? date;
  final VoidCallback onPick;

  /// Shows a clear button when set and a date is picked.
  final VoidCallback? onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: errorText == null ? AppColors.inputBorder : AppColors.error,
        ),
      ),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.event_outlined, color: AppColors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  date == null ? 'Pick a date' : shortDate(date!),
                  style: TextStyle(
                    fontSize: 16,
                    color: date == null ? AppColors.placeholder : AppColors.ink,
                  ),
                ),
              ),
              if (date != null && onClear != null)
                IconButton(
                  tooltip: 'Clear date',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
    if (errorText == null) return button;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        button,
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
