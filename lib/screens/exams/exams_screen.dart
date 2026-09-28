import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exam.dart';
import '../../state/course_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/app_header.dart';
import '../../widgets/pill_segments.dart';
import 'add_exam_screen.dart';

/// Which exams a tab shows. Quizzes and anything else share one tab.
enum ExamWeek {
  mid('Mid exams', 'MID EXAM WEEK'),
  finals('Final exams', 'FINAL EXAM WEEK'),
  other('Other', 'OTHER EXAMS');

  const ExamWeek(this.label, this.banner);

  final String label;
  final String banner;

  static ExamWeek of(ExamType type) => switch (type) {
        ExamType.mid => ExamWeek.mid,
        ExamType.finalExam => ExamWeek.finals,
        ExamType.quiz || ExamType.other => ExamWeek.other,
      };
}

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  /// Null until the student picks a tab; then their pick sticks.
  ExamWeek? _picked;

  void _openExam([Exam? exam]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AddExamScreen(existing: exam)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final term = state.term;
    final now = DateTime.now();
    final all = state.examsFor(term);

    // Open on the tab holding the next upcoming exam.
    final upcoming = all.where((e) => e.daysFrom(now) >= 0);
    final week = _picked ??
        (upcoming.isEmpty ? ExamWeek.mid : ExamWeek.of(upcoming.first.type));
    final exams = all.where((e) => ExamWeek.of(e.type) == week).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const AppHeader(),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                  child: Text('Exams',
                      style: AppTheme.display(34, color: AppColors.navy))),
              FilledButton.icon(
                onPressed: state.coursesFor(term).isEmpty ? null : _openExam,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add exam'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${term.code} term',
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          PillSegments<ExamWeek>(
            values: ExamWeek.values,
            selected: week,
            labelOf: (w) => w.label,
            onChanged: (w) => setState(() => _picked = w),
          ),
          const SizedBox(height: 14),
          if (state.coursesFor(term).isEmpty)
            _note('Add your ${term.code} courses first, then put their exams '
                'here.')
          else if (exams.isEmpty)
            _note('No ${week.label.toLowerCase()} yet. When the exam schedule '
                'comes out, tap Add exam for each one.')
          else ...[
            _WeekBanner(week: week, exams: exams, now: now),
            const SizedBox(height: 14),
            for (final day in _byDay(exams)) ...[
              _DayGroup(exams: day, onTap: _openExam),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  static Widget _note(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, height: 1.45, color: AppColors.muted),
        ),
      );

  /// Splits exams (already sorted) into runs that share a date.
  static List<List<Exam>> _byDay(List<Exam> exams) {
    final days = <List<Exam>>[];
    for (final e in exams) {
      if (days.isNotEmpty && days.last.first.date == e.date) {
        days.last.add(e);
      } else {
        days.add([e]);
      }
    }
    return days;
  }
}

class _WeekBanner extends StatelessWidget {
  const _WeekBanner({
    required this.week,
    required this.exams,
    required this.now,
  });

  final ExamWeek week;
  final List<Exam> exams;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final first = exams.first.date;
    final last = exams.last.date;
    final upcoming = exams.where((e) => e.daysFrom(now) >= 0).toList();
    final days = upcoming.isEmpty ? null : upcoming.first.daysFrom(now);
    final count = exams.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${week.banner} · $count ${count == 1 ? 'EXAM' : 'EXAMS'}',
                  style: AppTheme.eyebrow(color: AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  first == last
                      ? shortDate(first)
                      : '${shortDate(first)} – ${shortDate(last)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days == null ? 'Done' : (days == 0 ? 'Today' : '$days'),
                style: AppTheme.display(28, color: AppColors.navy),
              ),
              if (days != null && days > 0)
                Text(
                  days == 1 ? 'day to go' : 'days to go',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.exams, required this.onTap});

  final List<Exam> exams;
  final ValueChanged<Exam> onTap;

  @override
  Widget build(BuildContext context) {
    final date = exams.first.date;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                Text(weekdayCode(date),
                    style: AppTheme.eyebrow(color: AppColors.muted)),
                Text('${date.day}', style: AppTheme.display(24)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < exams.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                _ExamCard(exam: exams[i], onTap: () => onTap(exams[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onTap});

  final Exam exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final course = context.read<CourseState>().byId(exam.courseId);
    final isFinal = exam.type == ExamType.finalExam;
    const detail = TextStyle(fontSize: 13, color: AppColors.muted);

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course == null
                          ? 'Deleted course'
                          : '${course.code} ${course.title}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFinal ? const Color(0xFFE0E7FF) : AppColors.pill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      exam.type.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFinal ? AppColors.navy : AppColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Text(clockTime(exam.startMinutes), style: detail),
                  if (exam.room != null) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.place_outlined,
                        size: 14, color: AppColors.muted),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(exam.room!,
                          style: detail, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
