
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/plan_view_model.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Daily Plan",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.plan == null
              ? Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlanViewModel>().loadPlan(forceNew: true);
                    },
                    child: const Text(
                      "Generate Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _mealCard(
                        context,
                        title: "Breakfast 🍳",
                        text: vm.plan!.breakfast,
                        calories: vm.plan!.breakfastCalories,
                      ),
                      _mealCard(
                        context,
                        title: "Lunch 🍗",
                        text: vm.plan!.lunch,
                        calories: vm.plan!.lunchCalories,
                      ),
                      _mealCard(
                        context,
                        title: "Dinner 🍲",
                        text: vm.plan!.dinner,
                        calories: vm.plan!.dinnerCalories,
                      ),
                      _mealCard(
                        context,
                        title: "Snack 🍎",
                        text: vm.plan!.snack,
                        calories: vm.plan!.snackCalories,
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          "Total: ${vm.plan!.totalCalories} kcal",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      const SizedBox(height: 20),

                  
                      Padding(
  padding: const EdgeInsets.only(bottom: 50),
  child: ElevatedButton.icon(
    onPressed: () {
      context.read<PlanViewModel>().loadPlan(forceNew: true);
    },
    icon: const Icon(Icons.refresh),
    label: const Text(
      "Generate New Plan",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
)
                    ],
                  ),
                ),
    );
  }

  Widget _mealCard(
    BuildContext context, {
    required String title,
    required String text,
    required int calories,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$calories kcal",
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 12),

          Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}