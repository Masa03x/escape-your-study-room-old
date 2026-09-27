import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'game_art.dart';

class StudyRoom extends StatelessWidget {
  const StudyRoom({
    super.key,
    required this.roundProgress,
    required this.score,
    required this.dodged,
    required this.paused,
    this.onDemoTap,
  });

  final double roundProgress;
  final int score;
  final bool dodged;
  final bool paused;
  final VoidCallback? onDemoTap;

  static const _bookColors = [
    AppColors.red,
    AppColors.blue,
    Color(0xFFD97706),
    AppColors.purple,
    Color(0xFFDC2626),
  ];

  static const _bookSpines = [
    AppColors.redDark,
    AppColors.blueDark,
    Color(0xFF92400E),
    AppColors.purpleDark,
    AppColors.redDark,
  ];

  static const _titles = ['MATHS', 'HISTORY', 'ESSAY', 'THESIS', 'ALGEBRA'];

  @override
  Widget build(BuildContext context) {
    final nearEnd = score >= 4;
    final doorGlow = score >= 2;
    final doorBright = score >= 4;
    final index = math.min(score, 4);
    final emotion = score >= 4
        ? BookEmotion.dizzy
        : score >= 2
        ? BookEmotion.scared
        : BookEmotion.angry;

    return GestureDetector(
      key: const Key('game-room'),
      behavior: HitTestBehavior.opaque,
      onTap: onDemoTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final t = Curves.easeOutCubic.transform(roundProgress.clamp(0.0, 1.0));
          final bookX = width + 30 - (width * 0.55) * t;
          final bookY = height * (0.44 + math.sin(t * math.pi) * -0.05);

          return ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: nearEnd
                            ? const [Color(0xFF0A1A12), AppColors.bgDeepest]
                            : const [Color(0xFF131030), Color(0xFF0E0C28), Color(0xFF1A1400)],
                        stops: nearEnd ? null : const [0, 0.78, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(left: 8, top: 18, child: _Bookshelf(scale: width / 300)),
                Positioned(left: width * 0.23, top: 18, child: const _Clock()),
                Positioned(
                  right: width * 0.24,
                  top: 16,
                  child: _Window(nearEnd: nearEnd),
                ),
                Positioned(
                  right: 10,
                  bottom: 28,
                  child: _ExitDoor(glow: doorGlow, bright: doorBright),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 30,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D1A00), Color(0xFF1A1000), Color(0xFF2D1A00)],
                      ),
                      border: Border(top: BorderSide(color: Color(0xFF3D2500), width: 2)),
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.23,
                  bottom: dodged ? 23 : 26,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: StudentCharacter(
                      key: ValueKey(dodged),
                      width: dodged ? 88 : 70,
                      squatting: dodged,
                      confident: score >= 4,
                    ),
                  ),
                ),
                Positioned(
                  left: bookX,
                  top: bookY,
                  child: AnimatedOpacity(
                    opacity: dodged ? 0.18 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: FlyingBook(
                      width: 84,
                      bookColor: _bookColors[index],
                      spineColor: _bookSpines[index],
                      title: _titles[index],
                      emotion: emotion,
                      rotation: -0.14 + (math.sin(t * math.pi * 2) * 0.05),
                    ),
                  ),
                ),
                Positioned(
                  top: height * 0.12,
                  left: width * 0.40,
                  child: Transform.rotate(
                    angle: 0.1 - roundProgress * 0.18,
                    child: Container(
                      width: 30,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3).withValues(alpha: nearEnd ? 0.25 : 0.70),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Icon(Icons.notes, color: Color(0xFFD1D5DB), size: 18),
                    ),
                  ),
                ),
                if (nearEnd)
                  ...List.generate(5, (i) {
                    return Positioned(
                      left: 22.0 + i * (width - 44) / 5,
                      bottom: 50 + (i.isEven ? 8 : 0),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                if (paused)
                  Positioned.fill(
                    child: ColoredBox(color: AppColors.bgDeepest.withValues(alpha: 0.55)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Bookshelf extends StatelessWidget {
  const _Bookshelf({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale.clamp(0.8, 1.2);
    return Container(
      width: 52 * s,
      height: 110 * s,
      padding: EdgeInsets.all(3 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1A00),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ShelfRow(scale: s, colors: const [AppColors.blue, AppColors.red, Color(0xFF166534), Color(0xFF92400E)]),
          _ShelfRow(scale: s, colors: const [AppColors.purple, AppColors.blue, AppColors.red, AppColors.orange]),
          _ShelfRow(scale: s, colors: const [Color(0xFF166534), AppColors.purple, AppColors.red, AppColors.blue]),
        ],
      ),
    );
  }
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({required this.scale, required this.colors});
  final double scale;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29 * scale,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A0F00), width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < colors.length; i++)
            Transform.rotate(
              angle: i == 0 ? 0.05 : i == 2 ? -0.04 : 0,
              child: Container(
                width: (8 + (i % 2) * 2) * scale,
                height: (20 + (i % 3) * 3) * scale,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CustomPaint(painter: _ClockPainter()),
    );
  }
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = AppColors.text;
    canvas.drawLine(c, Offset(c.dx, 7), p);
    canvas.drawLine(c, Offset(c.dx + 9, c.dy + 3), p);
    canvas.drawCircle(c, 2.2, Paint()..color = AppColors.orange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Window extends StatelessWidget {
  const _Window({required this.nearEnd});
  final bool nearEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderLight, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: nearEnd
              ? [AppColors.green.withValues(alpha: 0.18), const Color(0xFF15803D).withValues(alpha: 0.08)]
              : [const Color(0xFF1E1B4A).withValues(alpha: 0.8), const Color(0xFF0F0D2E).withValues(alpha: 0.6)],
        ),
        boxShadow: nearEnd
            ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.25), blurRadius: 18)]
            : null,
      ),
      child: Stack(
        children: [
          const Center(child: VerticalDivider(width: 2, thickness: 2, color: AppColors.borderLight)),
          const Center(child: Divider(height: 2, thickness: 2, color: AppColors.borderLight)),
          Positioned(left: 8, top: 7, child: _star(3)),
          Positioned(left: 19, top: 14, child: _star(2)),
        ],
      ),
    );
  }

  Widget _star(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.65), shape: BoxShape.circle),
  );
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.glow, required this.bright});
  final bool glow;
  final bool bright;

  @override
  Widget build(BuildContext context) {
    final green = bright ? AppColors.green : AppColors.green.withValues(alpha: 0.45);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 58,
      height: 104,
      decoration: BoxDecoration(
        color: const Color(0xFF2D1A00),
        borderRadius: BorderRadius.circular(4),
        border: glow ? Border.all(color: green, width: bright ? 3 : 1.5) : null,
        boxShadow: glow
            ? [BoxShadow(color: green.withValues(alpha: bright ? 0.65 : 0.30), blurRadius: bright ? 22 : 10)]
            : null,
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bright
                    ? const Color(0xFF0A2412)
                    : glow
                    ? const Color(0xFF0A1A10)
                    : const Color(0xFF1A1A0A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(left: 5, right: 5, top: 6, height: 25, child: Row(children: [Expanded(child: _panel()), const SizedBox(width: 3), Expanded(child: _panel())])),
          Positioned(left: 5, right: 5, top: 35, height: 38, child: _panel()),
          Positioned(left: 6, top: 48, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: glow ? AppColors.green : const Color(0xFF374151), shape: BoxShape.circle))),
          Positioned(
            left: 5,
            right: 5,
            bottom: 4,
            height: 15,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bright ? AppColors.green : glow ? const Color(0xFF166534) : const Color(0xFF141404),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'EXIT →',
                style: AppText.body(
                  size: 7,
                  color: bright ? AppColors.bgDeepest : const Color(0xFF4B5563),
                  weight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel() => Container(
    decoration: BoxDecoration(
      color: bright ? const Color(0xFF0F3320) : const Color(0xFF141404),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
