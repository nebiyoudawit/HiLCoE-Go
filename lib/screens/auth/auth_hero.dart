import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';

/// Blue top half of the log in / sign up screen: logo, a few glassy
/// preview cards of what the app tracks, and the headline.
class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.signUp});

  final bool signUp;

  /// Cards take this much height at most; the longer sign-up form gets
  /// less so the whole screen fits on a phone without scrolling.
  double get _cardsHeight => signUp ? 108 : 140;

  @override
  Widget build(BuildContext context) {
    // Width the cards lay out at before being scaled down to fit.
    final cardsWidth = MediaQuery.sizeOf(context).width - 48;

    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _Swooshes())),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandMark(),
                  const Spacer(),
                  if (signUp) const _BatchChip(),
                ],
              ),
              const SizedBox(height: 14),
              // Spacers on both sides centre the cards in any spare room.
              const Spacer(),
              SizedBox(
                height: _cardsHeight,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: cardsWidth,
                    child: const _PreviewCards(),
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Text(
                signUp ? 'Join HiLCoE Go' : 'Welcome back',
                style: AppTheme.display(30, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your semester, organized in one place.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              if (!signUp) ...[
                const SizedBox(height: 4),
                const Text(
                  'Log in to pick up where you left off.',
                  style: TextStyle(fontSize: 14, color: AppColors.onBlueMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Faint curved lines across the blue for a bit of depth.
class _Swooshes extends CustomPainter {
  const _Swooshes();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.10);
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < 3; i++) {
      final dy = i * 26.0;
      canvas.drawPath(
        Path()
          ..moveTo(-20, h * 0.42 + dy)
          ..cubicTo(w * 0.3, h * 0.18 + dy, w * 0.65, h * 0.62 + dy, w + 20,
              h * 0.28 + dy),
        paint,
      );
    }
    // A soft glow behind the cards.
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.22),
      math.min(w, h) * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(
          center: Offset(w * 0.78, h * 0.22),
          radius: math.min(w, h) * 0.45,
        )),
    );
  }

  @override
  bool shouldRepaint(_Swooshes oldDelegate) => false;
}

/// Decorative sample cards: today's classes, course progress, next exam.
class _PreviewCards extends StatelessWidget {
  const _PreviewCards();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: _Tilt(degrees: -3, child: _TodayCard()),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _Tilt(degrees: 3, child: _ProgressCard()),
                SizedBox(height: 10),
                _Tilt(degrees: 4, child: _NextExamCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tilt extends StatelessWidget {
  const _Tilt({required this.degrees, required this.child});

  final double degrees;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Transform.rotate(angle: degrees * math.pi / 180, child: child);
}

/// Frosted card on the blue background.
class _Glass extends StatelessWidget {
  const _Glass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330A1A5C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 12),
        child: child,
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  static const _rows = [
    ('8:00', 'Data Structures'),
    ('9:45', 'Linear Algebra'),
    ('14:00', 'Physics Lab'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(Icons.calendar_today_outlined, 'Today'),
          for (final (time, name) in _rows) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 34,
                  child: Text(time,
                      style: const TextStyle(color: AppColors.onBlueMuted)),
                ),
                Expanded(
                  child: Text(name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return _Glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(Icons.bar_chart_rounded, 'Course progress'),
          const SizedBox(height: 6),
          const Text('Data Structures',
              style: TextStyle(color: AppColors.onBlueMuted)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 6,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('82%', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextExamCard extends StatelessWidget {
  const _NextExamCard();

  @override
  Widget build(BuildContext context) {
    return const _Glass(
      child: Row(
        children: [
          Icon(Icons.event_note_outlined, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next exam',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Oct 26 · Math',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.onBlueMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

class _BatchChip extends StatelessWidget {
  const _BatchChip();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x380F172A),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BATCH', style: AppTheme.eyebrow(size: 10)),
            const Text(
              'DRB2301',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
