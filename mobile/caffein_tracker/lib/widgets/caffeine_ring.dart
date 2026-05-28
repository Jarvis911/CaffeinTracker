import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CaffeineRing extends StatelessWidget {
  const CaffeineRing({
    super.key,
    required this.percent,
    required this.consumed,
    required this.limit,
  });

  final double percent;
  final int consumed;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RingPainter(percent.clamp(0, 100) / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$consumed',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const Text('mg', style: TextStyle(color: AppColors.textMuted)),
              Text(
                'of $limit mg',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 12.0;

    final track = Paint()
      ..color = const Color(0xFFF5EBE6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [AppColors.accent, AppColors.accentDeep],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
