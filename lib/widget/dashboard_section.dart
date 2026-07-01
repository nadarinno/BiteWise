import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/widget/calories_chart.dart';
import 'package:bitewise/widget/dashboard_state_card.dart';
import 'package:bitewise/widget/summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    final todayCalories = vm.todayCalories;
    final goalCalories = vm.goalCalories <= 0 ? 2000 : vm.goalCalories;

    final remainingCalories =
        goalCalories - todayCalories < 0 ? 0 : goalCalories - todayCalories;

    final todayProgress = goalCalories == 0 ? 0.0 : todayCalories / goalCalories;
    final remainingProgress =
        goalCalories == 0 ? 0.0 : remainingCalories / goalCalories;

    final weeklyCalories = vm.weeklyCalories.isEmpty
        ? List<int>.filled(7, 0)
        : vm.weeklyCalories;

    final totalCalories =
        weeklyCalories.fold<int>(0, (sum, value) => sum + value);

    
     final weeklyGoal = goalCalories * 7; 


    final highestintake = weeklyCalories.isEmpty
        ? 0
        : weeklyCalories.reduce((a, b) => a > b ? a : b);

    final streak = weeklyCalories.where((value) => value > 0).length;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return Column(
                children: [
                  DashboardStatCard(
                    title: "Today",
                    subtitle: "Calories Consumed",
                    value: todayCalories,
                    label:
                        "${(todayProgress * 100).clamp(0, 100).round()}% of goal",
                    icon: Icons.local_fire_department_outlined,
                    progress: todayProgress,
                  ),
                  const SizedBox(height: 14),
                  DashboardStatCard(
                    title: "Goal",
                    subtitle: "Daily Calories",
                    value: goalCalories,
                    label: "Daily target",
                    icon: Icons.track_changes,
                    progress: 1,
                  ),
                  const SizedBox(height: 14),
                  DashboardStatCard(
                    title: "Remaining",
                    subtitle: "Calories Left",
                    value: remainingCalories,
                    label:
                        "${(remainingProgress * 100).clamp(0, 100).round()}% left",
                    icon: Icons.bolt_outlined,
                    progress: remainingProgress,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: "Today",
                    subtitle: "Calories Consumed",
                    value: todayCalories,
                    label:
                        "${(todayProgress * 100).clamp(0, 100).round()}% of goal",
                    icon: Icons.local_fire_department_outlined,
                    progress: todayProgress,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DashboardStatCard(
                    title: "Goal",
                    subtitle: "Daily Calories",
                    value: goalCalories,
                    label: "Daily target",
                    icon: Icons.track_changes,
                    progress: 1,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DashboardStatCard(
                    title: "Remaining",
                    subtitle: "Calories Left",
                    value: remainingCalories,
                    label:
                        "${(remainingProgress * 100).clamp(0, 100).round()}% left",
                    icon: Icons.bolt_outlined,
                    progress: remainingProgress,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    IconButton(
      onPressed: vm.goToPreviousWeek,
      icon: const Icon(Icons.chevron_left),
    ),
    Column(
      children: [
        Text(
          vm.isCurrentWeek ? "This Week" : "Selected Week",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          vm.selectedWeekText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
    IconButton(
      onPressed: vm.goToNextWeek,
      icon: const Icon(Icons.chevron_right),
    ),
  ],
),
  const SizedBox(height: 20),

CaloriesChartModern(
  calories: vm.weeklyCalories,
  goal: vm.goalCalories,
  todayCalories: vm.todayCalories,
  remainingCalories: vm.remainingCalories,
  takenCalories: vm.todayCalories,
  highlightedIndex: vm.highlightedDayIndex,
),

        const SizedBox(height: 20),

        SummaryBar(
          weeklyGoal: weeklyGoal,
          totalCalories: totalCalories,
          highestintake: highestintake,
          streak: streak,
        ),
      ],
    );
  }
}