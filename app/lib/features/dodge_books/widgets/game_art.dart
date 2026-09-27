import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum BookEmotion { angry, scared, dizzy }

class FlyingBook extends StatelessWidget {
  const FlyingBook({
    super.key,
    this.width = 84,
    this.bookColor = AppColors.red,
    this.spineColor = AppColors.redDark,
    this.title = 'MATHS',
    this.emotion = BookEmotion.angry,
    this.rotation = -0.12,
    this.showMotionLines = true,
  });

  final double width;
  final Color bookColor;
  final Color spineColor;
  final String title;
  final BookEmotion emotion;
  final double rotation;
  final bool showMotionLines;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, width * 1.25),
        painter: _FlyingBookPainter(
          bookColor: bookColor,
          spineColor: spineColor,
          title: title,
          emotion: emotion,
          showMotionLines: showMotionLines,
        ),
      ),
    );
  }
}

class _FlyingBookPainter extends CustomPainter {
  _FlyingBookPainter({
    required this.bookColor,
    required this.spineColor,
    required this.title,
    required this.emotion,
    required this.showMotionLines,
  });

  final Color bookColor;
  final Color spineColor;
  final String title;
  final BookEmotion emotion;
  final bool showMotionLines;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 80;
    final sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    if (showMotionLines) {
      final motion = Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-5, 28), const Offset(-19, 28), motion);
      motion
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(-5, 38), const Offset(-24, 38), motion);
      motion
        ..color = Colors.white.withValues(alpha: 0.14)
        ..strokeWidth = 1.5;
      canvas.drawLine(const Offset(-5, 48), const Offset(-16, 48), motion);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(73, 5, 4, 88), const Radius.circular(2)),
      Paint()..color = const Color(0xFFFFF5F5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(5, 3, 70, 92), const Radius.circular(6)),
      Paint()..color = bookColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(5, 3, 13, 92), const Radius.circular(5)),
      Paint()..color = spineColor,
    );

    _text(canvas, title, const Offset(44, 14), 6.2, Colors.white.withValues(alpha: 0.70), bold: true, centered: true);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22, 25, 44, 2.5), const Radius.circular(1.2)),
      Paint()..color = Colors.white.withValues(alpha: 0.20),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22, 30, 30, 2), const Radius.circular(1)),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(44, 65), width: 52, height: 48),
      Paint()..color = const Color(0xFFFEF2F2),
    );

    switch (emotion) {
      case BookEmotion.angry:
        _paintAngry(canvas);
        break;
      case BookEmotion.scared:
        _paintScared(canvas);
        break;
      case BookEmotion.dizzy:
        _paintDizzy(canvas);
        break;
    }
    canvas.restore();
  }

  void _paintAngry(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF1F2937);
    canvas.drawOval(Rect.fromCenter(center: Offset(36, 60), width: 10, height: 10), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(52, 60), width: 10, height: 10), dark);
    canvas.drawCircle(const Offset(37, 58.5), 1.8, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(53, 58.5), 1.8, Paint()..color = Colors.white);
    final stroke = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(28, 51), const Offset(43, 56), stroke);
    canvas.drawLine(const Offset(60, 51), const Offset(45, 56), stroke);
    final mouth = Path()
      ..moveTo(33, 75)
      ..quadraticBezierTo(44, 70, 55, 75);
    canvas.drawPath(mouth, stroke..strokeWidth = 2.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(29, 68), width: 10, height: 6),
      Paint()..color = AppColors.red.withValues(alpha: 0.28),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(59, 68), width: 10, height: 6),
      Paint()..color = AppColors.red.withValues(alpha: 0.28),
    );
    final arm = Paint()
      ..color = bookColor
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(5, 58), const Offset(-9, 48), arm);
    canvas.drawLine(const Offset(75, 58), const Offset(89, 48), arm);
    canvas.drawCircle(const Offset(-9, 47), 7, Paint()..color = spineColor);
    canvas.drawCircle(const Offset(89, 47), 7, Paint()..color = spineColor);
  }

  void _paintScared(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF1F2937);
    canvas.drawOval(Rect.fromCenter(center: Offset(36, 60), width: 11, height: 12), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(52, 60), width: 11, height: 12), dark);
    canvas.drawCircle(const Offset(37, 57), 2, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(53, 57), 2, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(44, 75), width: 14, height: 10), dark);
  }

  void _paintDizzy(Canvas canvas) {
    final stroke = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final center in [const Offset(36, 61), const Offset(54, 61)]) {
      canvas.drawLine(center + const Offset(-6, -6), center + const Offset(6, 6), stroke);
      canvas.drawLine(center + const Offset(6, -6), center + const Offset(-6, 6), stroke);
    }
    final mouth = Path()
      ..moveTo(32, 75)
      ..quadraticBezierTo(36, 79, 44, 75)
      ..quadraticBezierTo(52, 71, 56, 75);
    canvas.drawPath(mouth, stroke..strokeWidth = 2);
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double size,
    Color color, {
    bool bold = false,
    bool centered = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, centered ? Offset(at.dx - painter.width / 2, at.dy) : at);
  }

  @override
  bool shouldRepaint(covariant _FlyingBookPainter oldDelegate) {
    return oldDelegate.bookColor != bookColor ||
        oldDelegate.spineColor != spineColor ||
        oldDelegate.title != title ||
        oldDelegate.emotion != emotion ||
        oldDelegate.showMotionLines != showMotionLines;
  }
}

class StudentCharacter extends StatelessWidget {
  const StudentCharacter({
    super.key,
    this.width = 72,
    this.squatting = false,
    this.confident = false,
  });

  final double width;
  final bool squatting;
  final bool confident;

  @override
  Widget build(BuildContext context) {
    final height = squatting ? width * 0.80 : width * 1.45;
    return CustomPaint(
      size: Size(width, height),
      painter: _StudentPainter(squatting: squatting, confident: confident),
    );
  }
}

class _StudentPainter extends CustomPainter {
  _StudentPainter({required this.squatting, required this.confident});
  final bool squatting;
  final bool confident;

  @override
  void paint(Canvas canvas, Size size) {
    if (squatting) {
      _paintSquat(canvas, size);
    } else {
      _paintStanding(canvas, size);
    }
  }

  void _paintStanding(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 58, size.height / 84);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(29, 83), width: 36, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    final jeans = Paint()
      ..color = AppColors.blueDark
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22, 57), const Offset(17, 77), jeans);
    canvas.drawLine(const Offset(36, 57), const Offset(42, 77), jeans);
    canvas.drawOval(Rect.fromCenter(center: Offset(16, 79), width: 18, height: 9), Paint()..color = const Color(0xFF1F2937));
    canvas.drawOval(Rect.fromCenter(center: Offset(43, 79), width: 18, height: 9), Paint()..color = const Color(0xFF1F2937));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(14, 25, 30, 34), const Radius.circular(6)),
      Paint()..color = AppColors.purple,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(43, 27, 12, 22), const Radius.circular(3.5)),
      Paint()..color = AppColors.purpleDark,
    );
    final skin = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    if (confident) {
      canvas.drawLine(const Offset(14, 33), const Offset(4, 40), skin);
      canvas.drawLine(const Offset(44, 33), const Offset(56, 28), skin);
      canvas.drawCircle(const Offset(56, 27), 4.5, Paint()..color = const Color(0xFFFBBF24));
    } else {
      canvas.drawLine(const Offset(14, 33), const Offset(2, 22), skin);
      canvas.drawLine(const Offset(44, 33), const Offset(56, 22), skin);
      canvas.drawCircle(const Offset(2, 21), 4.5, Paint()..color = const Color(0xFFFBBF24));
      canvas.drawCircle(const Offset(56, 21), 4.5, Paint()..color = const Color(0xFFFBBF24));
    }
    canvas.drawCircle(const Offset(29, 16), 14, Paint()..color = const Color(0xFFFBBF24));
    final hair = Path()
      ..moveTo(15, 13)
      ..quadraticBezierTo(15, 1, 29, 1)
      ..quadraticBezierTo(43, 1, 43, 13)
      ..quadraticBezierTo(40, 8, 29, 9)
      ..quadraticBezierTo(18, 9, 15, 13);
    canvas.drawPath(hair, Paint()..color = const Color(0xFF1F2937));
    final face = Paint()..color = const Color(0xFF1F2937);
    canvas.drawOval(Rect.fromCenter(center: Offset(24, 16), width: 5.6, height: 6), face);
    canvas.drawOval(Rect.fromCenter(center: Offset(34, 16), width: 5.6, height: 6), face);
    final mouth = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (confident) {
      final p = Path()
        ..moveTo(22, 22)
        ..quadraticBezierTo(29, 27, 36, 22);
      canvas.drawPath(p, mouth);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(29, 22), width: 8, height: 7), Paint()..color = AppColors.red);
    }
    canvas.restore();
  }

  void _paintSquat(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 90, size.height / 72);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(45, 71), width: 56, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    final jeans = Paint()
      ..color = AppColors.blueDark
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final leftLeg = Path()
      ..moveTo(33, 44)
      ..quadraticBezierTo(20, 56, 12, 65);
    final rightLeg = Path()
      ..moveTo(49, 44)
      ..quadraticBezierTo(63, 56, 73, 65);
    canvas.drawPath(leftLeg, jeans);
    canvas.drawPath(rightLeg, jeans);
    canvas.drawOval(Rect.fromCenter(center: Offset(10, 66), width: 22, height: 10), Paint()..color = const Color(0xFF1F2937));
    canvas.drawOval(Rect.fromCenter(center: Offset(74, 66), width: 22, height: 10), Paint()..color = const Color(0xFF1F2937));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 22, 34, 24), const Radius.circular(6)),
      Paint()..color = AppColors.purple,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(57, 24, 13, 18), const Radius.circular(3.5)),
      Paint()..color = AppColors.purpleDark,
    );
    final skin = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(24, 31), const Offset(6, 42), skin);
    canvas.drawLine(const Offset(58, 31), const Offset(76, 44), skin);
    canvas.drawCircle(const Offset(6, 42), 4.5, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(const Offset(76, 44), 4.5, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(const Offset(41, 14), 13, Paint()..color = const Color(0xFFFBBF24));
    final hair = Path()
      ..moveTo(28, 12)
      ..quadraticBezierTo(28, 1, 41, 1)
      ..quadraticBezierTo(54, 1, 54, 12)
      ..quadraticBezierTo(51, 7, 41, 8)
      ..quadraticBezierTo(31, 8, 28, 12);
    canvas.drawPath(hair, Paint()..color = const Color(0xFF1F2937));
    final face = Paint()..color = const Color(0xFF1F2937);
    canvas.drawOval(Rect.fromCenter(center: Offset(36, 14), width: 5.6, height: 5.6), face);
    canvas.drawOval(Rect.fromCenter(center: Offset(46, 14), width: 5.6, height: 5.6), face);
    final smile = Path()
      ..moveTo(34, 20)
      ..quadraticBezierTo(41, 24, 48, 20);
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF1F2937)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StudentPainter oldDelegate) =>
      oldDelegate.squatting != squatting || oldDelegate.confident != confident;
}

class DefeatedBook extends StatelessWidget {
  const DefeatedBook({
    super.key,
    this.width = 56,
    this.bookColor = AppColors.red,
    this.spineColor = AppColors.redDark,
  });

  final double width;
  final Color bookColor;
  final Color spineColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.55),
      painter: _DefeatedBookPainter(bookColor, spineColor),
    );
  }
}

class _DefeatedBookPainter extends CustomPainter {
  _DefeatedBookPainter(this.bookColor, this.spineColor);
  final Color bookColor;
  final Color spineColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 18, 94, 34), const Radius.circular(5)),
      Paint()..color = bookColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 18, 94, 10), const Radius.circular(4)),
      Paint()..color = spineColor,
    );
    final eyePaint = Paint()..color = const Color(0xFFFEF2F2);
    canvas.drawOval(Rect.fromCenter(center: Offset(35, 36), width: 28, height: 24), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(65, 36), width: 28, height: 24), eyePaint);
    final x = Paint()
      ..color = spineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (final c in [const Offset(31, 34), const Offset(61, 34)]) {
      canvas.drawLine(c + const Offset(-5, -5), c + const Offset(5, 5), x);
      canvas.drawLine(c + const Offset(5, -5), c + const Offset(-5, 5), x);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DefeatedBookPainter oldDelegate) =>
      oldDelegate.bookColor != bookColor || oldDelegate.spineColor != spineColor;
}

class MovementMiniDiagram extends StatelessWidget {
  const MovementMiniDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const _PoseIcon(squat: false, color: AppColors.purpleLight, label: 'Stand'),
        Text('→', style: AppText.heading(size: 20, color: AppColors.orange)),
        const _PoseIcon(squat: true, color: AppColors.green, label: 'Squat!'),
      ],
    );
  }
}

class _PoseIcon extends StatelessWidget {
  const _PoseIcon({required this.squat, required this.color, required this.label});
  final bool squat;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: squat ? 52 : 42,
          height: 54,
          child: CustomPaint(painter: _PosePainter(squat: squat, color: color)),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppText.body(size: 10, color: AppColors.textMuted, weight: FontWeight.w700)),
      ],
    );
  }
}

class _PosePainter extends CustomPainter {
  _PosePainter({required this.squat, required this.color});
  final bool squat;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (!squat) {
      canvas.drawCircle(Offset(size.width / 2, 9), 7, Paint()..color = color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2 - 6, 16, 12, 17), const Radius.circular(3)),
        Paint()..color = color,
      );
      canvas.drawLine(Offset(size.width / 2 - 3, 33), Offset(size.width / 2 - 5, 49), paint);
      canvas.drawLine(Offset(size.width / 2 + 3, 33), Offset(size.width / 2 + 5, 49), paint);
      canvas.drawLine(Offset(size.width / 2 - 6, 23), const Offset(5, 30), paint);
      canvas.drawLine(Offset(size.width / 2 + 6, 23), Offset(size.width - 5, 30), paint);
    } else {
      canvas.drawCircle(Offset(size.width / 2, 9), 7, Paint()..color = color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2 - 6, 16, 12, 13), const Radius.circular(3)),
        Paint()..color = color,
      );
      final left = Path()
        ..moveTo(size.width / 2 - 3, 29)
        ..quadraticBezierTo(13, 39, 7, 50);
      final right = Path()
        ..moveTo(size.width / 2 + 3, 29)
        ..quadraticBezierTo(size.width - 14, 39, size.width - 7, 50);
      canvas.drawPath(left, paint);
      canvas.drawPath(right, paint);
      canvas.drawLine(Offset(size.width / 2 - 6, 22), const Offset(4, 31), paint);
      canvas.drawLine(Offset(size.width / 2 + 6, 22), Offset(size.width - 4, 31), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) => oldDelegate.squat != squat || oldDelegate.color != color;
}

class FloatingSparkles extends StatelessWidget {
  const FloatingSparkles({super.key, this.green = false});
  final bool green;

  @override
  Widget build(BuildContext context) {
    final points = <Offset>[
      const Offset(0.08, 0.12),
      const Offset(0.88, 0.08),
      const Offset(0.22, 0.22),
      const Offset(0.70, 0.18),
      const Offset(0.45, 0.28),
      const Offset(0.15, 0.38),
      const Offset(0.82, 0.32),
      const Offset(0.60, 0.42),
    ];
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (var i = 0; i < points.length; i++)
                Positioned(
                  left: constraints.maxWidth * points[i].dx,
                  top: constraints.maxHeight * points[i].dy,
                  child: Container(
                    width: 2.5 + (i % 3),
                    height: 2.5 + (i % 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: green
                          ? (i.isEven ? AppColors.greenLight : AppColors.orange)
                          : (i % 3 == 0 ? AppColors.purpleLight : Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: (green ? AppColors.green : AppColors.purpleLight).withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
