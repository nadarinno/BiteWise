
import 'package:bitewise/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MiniCaloriesInfo extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const MiniCaloriesInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ).animate().scale(
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(width: 10),

            Expanded(
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 4),

                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: value),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedValue, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            "$animatedValue ${AppText.get(context, 'kcal')}",
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(.96, .96),
          curve: Curves.easeOutCubic,
        );
  }
}