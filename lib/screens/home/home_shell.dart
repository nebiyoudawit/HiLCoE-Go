import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

import '../courses/courses_screen.dart';
import '../exams/exams_screen.dart';
import '../schedule/schedule_screen.dart';
import 'home_screen.dart';

/// Signed-in layout: four tabs with the bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onOpenCourses: () => _go(1),
            onOpenExams: () => _go(3),
            onOpenSchedule: () => _go(2),
          ),
          const CoursesScreen(),
          const ScheduleScreen(),
          const ExamsScreen(),
        ],
      ),
      bottomNavigationBar: _NavBar(selected: _index, onSelect: _go),
    );
  }
}

/// Floating, fully rounded bottom bar. The selected tab gets a soft blue
/// pill behind a filled icon and its label.
class _NavBar extends StatelessWidget {
  const _NavBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Courses'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Schedule'),
    (
      Icons.assignment_turned_in_outlined,
      Icons.assignment_turned_in_rounded,
      'Exams'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1D4ED8),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _item(i, _items[i].$1, _items[i].$2, _items[i].$3),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = index == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(index),
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.tint : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.blue : AppColors.subtle,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.blue : AppColors.subtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
