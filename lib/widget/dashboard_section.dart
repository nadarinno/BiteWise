
import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/widget/calories_chart.dart';
import 'package:bitewise/widget/dashboard_state_card.dart';
import 'package:bitewise/widget/summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

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