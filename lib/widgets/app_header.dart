import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'account_sheet.dart';

/// Logo, app name and the student's batch, shown at the top of each tab.
/// Tapping the batch opens the account sheet.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final batch = context.select<AuthState, String?>((a) => a.user?.batch);
    return Row(
      children: [
        const AppLogo(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'HiLCoE Go',
            style: AppTheme.display(20, color: AppColors.navy)
                .copyWith(letterSpacing: -0.2),
          ),
        ),
        if (batch != null)
          Semantics(
            button: true,
            label: 'Account, batch $batch',
            child: Material(
              color: AppColors.tint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.pill),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => showAccountSheet(context),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('BATCH',
                            style: AppTheme.eyebrow(
                                color: AppColors.muted, size: 10)),
                        Text(
                          batch,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Blue rounded tile with the white graduation cap.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B6CF0), AppColors.blue],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331D4ED8),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child:
          Icon(Icons.school_outlined, color: Colors.white, size: size * 0.58),
    );
  }
}

/// Small icon + bold title used above sections, e.g. "Today's classes".
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.action,
  });

  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
