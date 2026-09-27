import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final String label;
  final IconData icon;
  final double progress;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.label,
    required this.icon,
    required this.progress,
  });

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final safeProgress = progress.clamp(0.0, 1.0);
  final isDark = theme.brightness == Brightness.dark;

  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 20,
              child: Icon(
                icon,
                size: 54,
                color: theme.colorScheme.onSurface.withOpacity(0.07),
              ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(.8, .8),
                    curve: Curves.easeOutBack,
                  ),
            ),

            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.22),
                ),
              ),
            ),

            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: safeProgress,
                  ),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedProgress, child) {
                    return CustomPaint(
                      painter: RingPainter(
                        progress: animatedProgress,
                        color: theme.colorScheme.primary,
                        trackColor: Colors.white.withOpacity(
                          isDark ? 0.10 : 0.35,
                        ),
                      ),
                      child: SizedBox(
                        width: 82,
                        height: 82,
                        child: Center(
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                isDark ? 0.07 : 0.30,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  isDark ? 0.10 : 0.45,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TweenAnimationBuilder<int>(
                                    tween: IntTween(begin: 0, end: value),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    builder:
                                        (context, animatedValue, child) {
                                      return FittedBox(
                                        child: Text(
                                          "$animatedValue",
                                          style: theme.textTheme.titleLarge,
                                        ),
                                      );
                                    },
                                  ),
                                  Text(
                                    "kcal",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 450.ms).scale(
                      begin: const Offset(.9, .9),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ).animate(delay: 120.ms).fadeIn(duration: 450.ms).slideX(
                      begin: .12,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ],
        ),
      ),
    ),
  ).animate().fadeIn(duration: 450.ms).slideY(
        begin: .12,
        curve: Curves.easeOutCubic,
      );
}
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final trackPaint = Paint()
      ..color = trackColor.withOpacity(0.45)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.28)
      ..strokeWidth = stroke + 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        8,
      );

    final softProgressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          color.withOpacity(0.55),
          color,
          color.withOpacity(0.85),
        ],
      ).createShader(rect)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        progress * 2 * pi,
        false,
        glowPaint,
      );

      canvas.drawArc(
        rect,
        -pi / 2,
        progress * 2 * pi,
        false,
        softProgressPaint,
      );
    }

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius - 6,
      ),
      -pi * 0.85,
      pi * 0.35,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}