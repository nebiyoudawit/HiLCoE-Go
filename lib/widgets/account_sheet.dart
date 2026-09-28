import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile/edit_profile_screen.dart';
import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'form_bits.dart';

/// Bottom sheet with the signed-in student's details, Edit profile and
/// Log out.
void showAccountSheet(BuildContext context) {
  final user = context.read<AuthState>().user;
  if (user == null) return;

  Widget chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
          ),
        ),
      );

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(user.name, style: AppTheme.display(24)),
            const SizedBox(height: 6),
            Text(user.email,
                style: const TextStyle(fontSize: 15, color: AppColors.muted)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip('Batch ${user.batch}'),
                if (user.studentId != null) chip('ID ${user.studentId}'),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Edit profile',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.read<AuthState>().logOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.border),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
