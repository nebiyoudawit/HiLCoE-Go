import 'package:flutter/material.dart';

import '../courses/courses_screen.dart';
import 'coming_soon_screen.dart';
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
          HomeScreen(onOpenCourses: () => _go(1)),
          const CoursesScreen(),
          const ComingSoonScreen(
            title: 'Schedule',
            icon: Icons.calendar_month_outlined,
            message: 'Your weekly timetable, imported from the university '
                'PDF or entered by hand, is coming next.',
          ),
          const ComingSoonScreen(
            title: 'Exams',
            icon: Icons.assignment_turned_in_outlined,
            message: 'Exam week with each exam\'s date, time and room '
                'is coming soon.',
          ),
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
