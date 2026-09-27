import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../state/auth_state.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../courses/course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenCourses});

  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final state = context.watch<CourseState>();
    final term = state.term;
    final courses = state.coursesFor(term);
    final now = DateTime.now();
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      longDate(now),
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${greeting(now)}, ${user.firstName}',
                      style: AppTheme.display(30),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AccountButton(user: user),
            ],
          ),
          const SizedBox(height: 18),
          _TermCard(
            termCode: term.code,
            courseCount: courses.length,
            creditHours: state.creditHoursFor(term),
            onTap: onOpenCourses,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'This term\'s courses',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: onOpenCourses, child: const Text('All')),
            ],
          ),
          const SizedBox(height: 4),
          if (courses.isEmpty)
            const Text(
              'Nothing here yet. Add the courses you registered for from the '
              'Courses tab.',
              style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < courses.length; i++) ...[
                    if (i > 0) const Divider(),
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CourseDetailScreen(courseId: courses[i].id),
                        ),
                      ),
                      title: Text(
                        courses[i].title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      leading: SizedBox(
                        width: 76,
                        child: Text(
                          courses[i].code,
                          style: AppTheme.eyebrow(),
                        ),
                      ),
                      minLeadingWidth: 76,
                      trailing: Text(
                        '${courses[i].creditHours} cr',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({
    required this.termCode,
    required this.courseCount,
    required this.creditHours,
    required this.onTap,
  });

  final String termCode;
  final int courseCount;
  final int creditHours;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$termCode TERM',
                style: AppTheme.eyebrow(color: AppColors.onBlueMuted, size: 13),
              ),
              const SizedBox(height: 8),
              Text(
                courseCount == 1 ? '1 course' : '$courseCount courses',
                style: AppTheme.display(28, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '$creditHours credit hours',
                style: const TextStyle(fontSize: 15, color: Color(0xFFE6EDFE)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Account',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _showAccount(context),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.pill,
          child: Text(
            user.initials,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  void _showAccount(BuildContext context) {
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
                  _chip('Batch ${user.batch}'),
                  if (user.studentId != null) _chip('ID ${user.studentId}'),
                ],
              ),
              const SizedBox(height: 20),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(String text) => Container(
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
}
