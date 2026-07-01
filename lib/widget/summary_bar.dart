
import 'package:bitewise/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SummaryBar extends StatelessWidget {
  final int weeklyGoal;
  final int totalCalories;
  final int highestintake;
  final int streak;

  const SummaryBar({
    super.key,
    required this.weeklyGoal,
    required this.totalCalories,
    required this.highestintake,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryItem(
                  icon: Icons.track_changes,
                  title: AppText.get(context, 'weeklyGoal'),
                  value: "$weeklyGoal",
                  unit: AppText.get(context, 'kcal'),
                ).animate(delay: 100.ms).fadeIn().slideX(begin: -.12),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SummaryItem(
                  icon: Icons.local_fire_department,
                  title: AppText.get(context, 'total'),
                  value: "$totalCalories",
                  unit: AppText.get(context, 'kcal'),
                ).animate(delay: 180.ms).fadeIn().slideX(begin: .12),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SummaryItem(
                  icon: Icons.rocket_launch_outlined,
                  title: AppText.get(context, 'highestIntake'),
                  value: "$highestintake",
                  unit: AppText.get(context, 'kcal'),
                ).animate(delay: 260.ms).fadeIn().slideX(begin: -.12),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: SummaryItem(
                  icon: Icons.calendar_month,
                  title: AppText.get(context, 'streak'),
                  value: "$streak",
                  unit: AppText.get(context, 'days'),
                ).animate(delay: 340.ms).fadeIn().slideX(begin: .12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).scale(
          begin: const Offset(.97, .97),
          curve: Curves.easeOutCubic,
        );
  }
}

class SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const SummaryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 21,
            ),
          ).animate().scale(
                duration: 350.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: " $unit",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}