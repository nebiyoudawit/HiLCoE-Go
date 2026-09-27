import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// White logo tile with the cap icon, followed by "HiLCoE Go".
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school_outlined, color: AppColors.blue),
        ),
        const SizedBox(width: 10),
        Text(
          'HiLCoE Go',
          style: AppTheme.display(22, color: Colors.white)
              .copyWith(letterSpacing: -0.2),
        ),
      ],
    );
  }
}
