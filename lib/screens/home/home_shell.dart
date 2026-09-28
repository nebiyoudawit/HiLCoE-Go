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

class _NavBar extends StatelessWidget {
  const _NavBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.menu_book_outlined, 'Courses'),
    (Icons.calendar_month_outlined, 'Schedule'),
    (Icons.assignment_turned_in_outlined, 'Exams'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(child: _item(i, _items[i].$1, _items[i].$2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final isSelected = index == selected;
    final color = isSelected ? AppColors.blue : AppColors.subtle;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: () => onSelect(index),
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 22 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
