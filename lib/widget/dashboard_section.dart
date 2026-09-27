

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/widget/calories_chart.dart';
import 'package:bitewise/widget/dashboard_state_card.dart';
import 'package:bitewise/widget/summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/widget/glass_container.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    final todayCalories = vm.todayCalories;
    final goalCalories = vm.goalCalories <= 0 ? 2000 : vm.goalCalories;

    final remainingCalories =
        goalCalories - todayCalories < 0 ? 0 : goalCalories - todayCalories;

    final todayProgress =
        goalCalories == 0 ? 0.0 : todayCalories / goalCalories;

    final remainingProgress =
        goalCalories == 0 ? 0.0 : remainingCalories / goalCalories;

    final weeklyCalories =
        vm.weeklyCalories.isEmpty ? List<int>.filled(7, 0) : vm.weeklyCalories;

    final totalCalories =
        weeklyCalories.fold<int>(0, (sum, value) => sum + value);

    final weeklyGoal = goalCalories * 7;

    final highestintake = weeklyCalories.isEmpty
        ? 0
        : weeklyCalories.reduce((a, b) => a > b ? a : b);

    final streak = weeklyCalories.where((value) => value > 0).length;

    final todayPercent = (todayProgress * 100).clamp(0, 100).round();
    final remainingPercent = (remainingProgress * 100).clamp(0, 100).round();

    final todayProtein = vm.todayProtein;
    final todayCarbs = vm.todayCarbs;
    final todayFats = vm.todayFats;
    final todayFiber = vm.todayFiber;

    final proteinGoal = vm.proteinGoal;
    final carbsGoal = vm.carbsGoal;
    final fatsGoal = vm.fatsGoal;
    final fiberGoal = vm.fiberGoal;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return Column(
                children: [
                  _statCard(
                    context: context,
                    title: AppText.get(context, 'today'),
                    subtitle: AppText.get(context, 'caloriesConsumed'),
                    value: todayCalories,
                    label: "$todayPercent% ${AppText.get(context, 'ofGoal')}",
                    icon: Icons.local_fire_department_outlined,
                    progress: todayProgress,
                  )
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),

                  const SizedBox(height: 14),

                  _statCard(
                    context: context,
                    title: AppText.get(context, 'goal'),
                    subtitle: AppText.get(context, 'dailyCalories'),
                    value: goalCalories,
                    label: AppText.get(context, 'dailyTarget'),
                    icon: Icons.track_changes,
                    progress: 1,
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),

                  const SizedBox(height: 14),

                  _statCard(
                    context: context,
                    title: AppText.get(context, 'remaining'),
                    subtitle: AppText.get(context, 'caloriesLeft'),
                    value: remainingCalories,
                    label:
                        "$remainingPercent% ${AppText.get(context, 'left')}",
                    icon: Icons.bolt_outlined,
                    progress: remainingProgress,
                  )
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _statCard(
                    context: context,
                    title: AppText.get(context, 'today'),
                    subtitle: AppText.get(context, 'caloriesConsumed'),
                    value: todayCalories,
                    label: "$todayPercent% ${AppText.get(context, 'ofGoal')}",
                    icon: Icons.local_fire_department_outlined,
                    progress: todayProgress,
                  )
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _statCard(
                    context: context,
                    title: AppText.get(context, 'goal'),
                    subtitle: AppText.get(context, 'dailyCalories'),
                    value: goalCalories,
                    label: AppText.get(context, 'dailyTarget'),
                    icon: Icons.track_changes,
                    progress: 1,
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _statCard(
                    context: context,
                    title: AppText.get(context, 'remaining'),
                    subtitle: AppText.get(context, 'caloriesLeft'),
                    value: remainingCalories,
                    label:
                        "$remainingPercent% ${AppText.get(context, 'left')}",
                    icon: Icons.bolt_outlined,
                    progress: remainingProgress,
                  )
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: .18),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        _macroProgressCard(
          context: context,
          protein: todayProtein,
          carbs: todayCarbs,
          fats: todayFats,
          fiber: todayFiber,
          proteinGoal: proteinGoal,
          carbsGoal: carbsGoal,
          fatsGoal: fatsGoal,
           fiberGoal: fiberGoal,
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 450.ms)
            .slideY(begin: .15),

        const SizedBox(height: 20),

        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _weekButton(
                icon: Icons.chevron_left,
                onPressed: vm.goToPreviousWeek,
              ),

              Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  children: [
                    Text(
                      vm.isCurrentWeek
                          ? AppText.get(context, 'thisWeek')
                          : AppText.get(context, 'selectedWeek'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vm.selectedWeekText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              _weekButton(
                icon: Icons.chevron_right,
                onPressed: vm.goToNextWeek,
              ),
            ],
          ),
        )
            .animate(delay: 320.ms)
            .fadeIn(duration: 420.ms)
            .slideY(begin: .14),

        const SizedBox(height: 20),

        CaloriesChartModern(
          calories: weeklyCalories,
          goal: goalCalories,
          todayCalories: todayCalories,
          remainingCalories: remainingCalories,
          takenCalories: todayCalories,
          highlightedIndex: vm.highlightedDayIndex,
        )
            .animate(delay: 420.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: .16),

        const SizedBox(height: 20),

        SummaryBar(
          weeklyGoal: weeklyGoal,
          totalCalories: totalCalories,
          highestintake: highestintake,
          streak: streak,
        )
            .animate(delay: 540.ms)
            .fadeIn(duration: 450.ms)
            .slideY(begin: .18),
      ],
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int value,
    required String label,
    required IconData icon,
    required double progress,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DashboardStatCard(
        title: title,
        subtitle: subtitle,
        value: value,
        label: label,
        icon: icon,
        progress: progress,
      ),
    );
  }


Widget _macroProgressCard({
  required BuildContext context,
  required int protein,
  required int carbs,
  required int fats,
  required int fiber,
  required int proteinGoal,
  required int carbsGoal,
  required int fatsGoal,
  required int fiberGoal,
}) {
  final theme = Theme.of(context);
  final isArabic = Directionality.of(context) == TextDirection.rtl;

  return GlassContainer(
    padding: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(24),
    blur: 18,
    opacity: 0.08,
    child: Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          AppText.get(context, 'todayMacros'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 14),

        _macroRow(
          context: context,
          title: AppText.get(context, 'protein'),
          value: protein,
          target: proteinGoal,
          icon: Icons.fitness_center,
        ),

        const SizedBox(height: 10),

        _macroRow(
          context: context,
          title: AppText.get(context, 'carbs'),
          value: carbs,
          target: carbsGoal,
          icon: Icons.rice_bowl,
        ),

        const SizedBox(height: 10),

        _macroRow(
          context: context,
          title: AppText.get(context, 'fats'),
          value: fats,
          target: fatsGoal,
          icon: Icons.water_drop_outlined,
        ),

        const SizedBox(height: 10),

        _macroRow(
          context: context,
          title: AppText.get(context, 'fiber'),
          value: fiber,
          target: fiberGoal,
          icon: Icons.grass,
        ),
      ],
    ),
  );
}

Widget _macroRow({
  required BuildContext context,
  required String title,
  required int value,
  required int target,
  required IconData icon,
}) {
  final theme = Theme.of(context);
  final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
  final isDark = theme.brightness == Brightness.dark;

  return GlassContainer(
    padding: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(18),
    blur: 10,
    opacity: 0.07,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.10 : 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.45),
            ),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(isDark ? 0.08 : 0.30),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "$value / $target g",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
  

  Widget _weekButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: const Duration(milliseconds: 180),
      builder: (context, scale, child) {
        return IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
        )
            .animate()
            .scale(
              begin: const Offset(.9, .9),
              duration: 280.ms,
              curve: Curves.easeOutBack,
            );
      },
    );
  }
}