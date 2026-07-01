
import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/nutrition_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          AppText.get(context, 'result'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: vm.isLoading
            ? const Center(
                key: ValueKey("loading"),
                child: CircularProgressIndicator(),
              )
            : vm.result == null
                ? Center(
                    key: const ValueKey("empty"),
                    child: Text(
                      AppText.get(context, 'noData'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NutritionViewModel vm) {
    final theme = Theme.of(context);
    final data = vm.result!;
    final mealType = vm.selectedMealType ?? "unknown";

    return SingleChildScrollView(
      key: const ValueKey("content"),
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
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          TextField(
            controller: mealDescriptionController,
            maxLines: 4,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: AppText.get(context, 'enterMealDetails'),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () async {
              final description = mealDescriptionController.text.trim();

              if (description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.get(context, 'enterMealDetailsFirst')),
                  ),
                );
                return;
              }
            
          
              final languageCode =
    context.read<LanguageViewModel>().locale.languageCode;

await context.read<NutritionViewModel>().calculateByMealDescription(
      description,
      languageCode: languageCode,
    );
            },
            icon: const Icon(Icons.calculate),
            label: Text(
              AppText.get(context, 'calculateMacros'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 12),

          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get(context, 'nutritionSummary'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${data.calories} ${AppText.get(context, 'kcal')}",
                  style: theme.textTheme.headlineMedium,
                ).animate().fadeIn(duration: 500.ms).scale(),
                const SizedBox(height: 20),
                _bar(
                  context,
                  AppText.get(context, 'protein'),
                  data.protein,
                  50,
                ),
                _bar(
                  context,
                  AppText.get(context, 'carbs'),
                  data.carbs,
                  300,
                ),
                _bar(
                  context,
                  AppText.get(context, 'fats'),
                  data.fats,
                  70,
                ),
                _bar(
                  context,
                  AppText.get(context, 'fiber'),
                  data.fiber,
                  30,
                ),
              ],
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 450.ms).slideY(begin: 0.12),

          const SizedBox(height: 18),

          _infoCard(
            context,
            title: AppText.get(context, 'advice'),
            icon: Icons.lightbulb,
            text: data.advice,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(begin: -0.12),

          const SizedBox(height: 12),

          _infoCard(
            context,
            title: AppText.get(context, 'alternativeMeal'),
            icon: Icons.restaurant,
            text: data.alternative,
          ).animate(delay: 380.ms).fadeIn(duration: 400.ms).slideX(begin: 0.12),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: SizedBox(
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
                            SnackBar(
                              content: Text(
                                AppText.get(context, 'mealSavedSuccessfully'),
                              ),
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
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _isSaving
                      ? Row(
                          key: const ValueKey("loading"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppText.get(context, 'saving'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey("save"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(width: 8),
                            Text(
                              AppText.get(context, 'saveMeal'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ).animate(delay: 450.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _mealTypeBadge(BuildContext context, String mealType) {
    final theme = Theme.of(context);

    String text = AppText.get(context, 'meal');

    if (mealType == "breakfast") {
      text = "${AppText.get(context, 'breakfast')} 🍳";
    }

    if (mealType == "lunch") {
      text = "${AppText.get(context, 'lunch')} 🍗";
    }

    if (mealType == "dinner") {
      text = "${AppText.get(context, 'dinner')} 🍲";
    }

    if (mealType == "snack") {
      text = "${AppText.get(context, 'snack')} 🍎";
    }

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
    ).animate().fadeIn(duration: 350.ms).scale();
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
                  text.isEmpty
                      ? AppText.get(context, 'enterQuantityFirst')
                      : text,
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
    final percent = (value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$name: ${value}g",
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 5),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: percent),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              value: animatedValue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.08);
  }
}