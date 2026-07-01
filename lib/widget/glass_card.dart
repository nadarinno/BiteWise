import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    )


        .animate()
        .fadeIn(
          duration: 450.ms,
        )
        .slideY(
          begin: .12,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(.97, .97),
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }
}