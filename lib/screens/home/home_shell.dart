import 'package:flutter/material.dart';

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
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_turned_in_outlined),
              selectedIcon: Icon(Icons.assignment_turned_in_rounded),
              label: 'Exams',
            ),
          ],
        ),
      ),
    );
  }
}
