import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/nutrition_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController mealDescriptionController =
      TextEditingController();
      
  bool _isSaving = false;
  @override
  void dispose() {
    mealDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Result",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.result == null
              ? Center(
                  child: Text(
                    "No Data",
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, NutritionViewModel vm) {
    final theme = Theme.of(context);
    final data = vm.result!;
    final mealType = vm.selectedMealType ?? "unknown";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.food,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                _mealTypeBadge(context, mealType),
              ],
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: mealDescriptionController,
            maxLines: 4,
            style: theme.textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: "Enter your meal details",
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () async {
              final description = mealDescriptionController.text.trim();

              if (description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enter meal details first"),
                  ),
                );
                return;
              }

              await context
                  .read<NutritionViewModel>()
                  .calculateByMealDescription(description);
            },
            icon: const Icon(Icons.calculate),
            label: const Text(
              "Calculate Macros",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nutrition Summary",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${data.calories} kcal",
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                _bar(context, "Protein", data.protein, 50),
                _bar(context, "Carbs", data.carbs, 300),
                _bar(context, "Fats", data.fats, 70),
                _bar(context, "Fiber", data.fiber, 30),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _infoCard(
            context,
            title: "Advice",
            icon: Icons.lightbulb,
            text: data.advice,
          ),

          const SizedBox(height: 12),

          _infoCard(
            context,
            title: "Alternative Meal",
            icon: Icons.restaurant,
            text: data.alternative,
          ),

     const SizedBox(height: 12),


SizedBox(
  width: double.infinity,
  height: 54,
  child: ElevatedButton(
    onPressed: data.calories == 0 || _isSaving
        ? null
        : () async {
            setState(() {
              _isSaving = true;
            });

            try {
              await context.read<NutritionViewModel>().saveMeal();

              if (!context.mounted) return;

              await context
                  .read<DashboardViewModel>()
                  .refreshAfterMealSaved();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Meal saved successfully"),
                ),
              );

              Navigator.pop(context);
            } finally {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            }
          },
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isSaving
          ? Row(
              key: const ValueKey("loading"),
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Saving...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : Row(
              key: const ValueKey("save"),
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text(
                  "Save Meal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    ),
  ),
)
        ],
      ),
    );
  }

  Widget _mealTypeBadge(BuildContext context, String mealType) {
    final theme = Theme.of(context);

    String text = "Meal";

    if (mealType == "breakfast") text = "Breakfast 🍳";
    if (mealType == "lunch") text = "Lunch 🍗";
    if (mealType == "dinner") text = "Dinner 🍲";
    if (mealType == "snack") text = "Snack 🍎";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text.isEmpty ? "Enter quantity first to get advice." : text,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    String name,
    int value,
    int goal,
  ) {
    final theme = Theme.of(context);
    final percent = value / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$name: ${value}g",
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: percent > 1 ? 1 : percent,
          minHeight: 8,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}