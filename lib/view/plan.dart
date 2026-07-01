
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:bitewise/utils/app_text.dart';
import '../viewmodel/plan_view_model.dart';
import '../viewmodel/language_view_model.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _generatePlan(BuildContext context) {
    final languageCode =
        context.read<LanguageViewModel>().locale.languageCode;

    context.read<PlanViewModel>().loadPlan(
          forceNew: true,
          languageCode: languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.get(context, 'dailyPlan'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: vm.isLoading
            ? const Center(
                key: ValueKey("loading"),
                child: CircularProgressIndicator(),
              )
            : vm.plan == null
                ? Center(
                    key: const ValueKey("empty"),
                    child: ElevatedButton(
                      onPressed: () {
                        _generatePlan(context);
                      },
                      child: Text(
                        AppText.get(context, 'generatePlan'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(curve: Curves.easeOutBack),
                  )
                : SingleChildScrollView(
                    key: const ValueKey("content"),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _mealCard(
                          context,
                          title: "${AppText.get(context, 'breakfast')} 🍳",
                          text: vm.plan!.breakfast,
                          calories: vm.plan!.breakfastCalories,
                          delay: 0,
                        ),

                        _mealCard(
                          context,
                          title: "${AppText.get(context, 'lunch')} 🍗",
                          text: vm.plan!.lunch,
                          calories: vm.plan!.lunchCalories,
                          delay: 100,
                        ),

                        _mealCard(
                          context,
                          title: "${AppText.get(context, 'dinner')} 🍲",
                          text: vm.plan!.dinner,
                          calories: vm.plan!.dinnerCalories,
                          delay: 200,
                        ),

                        _mealCard(
                          context,
                          title: "${AppText.get(context, 'snack')} 🍎",
                          text: vm.plan!.snack,
                          calories: vm.plan!.snackCalories,
                          delay: 300,
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
                          child: TweenAnimationBuilder<int>(
                            tween: IntTween(
                              begin: 0,
                              end: vm.plan!.totalCalories,
                            ),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedValue, child) {
                              return Text(
                                "${AppText.get(context, 'total')}: $animatedValue ${AppText.get(context, 'kcal')}",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              );
                            },
                          ),
                        )
                            .animate(delay: 420.ms)
                            .fadeIn(duration: 450.ms)
                            .slideY(begin: .15),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _generatePlan(context);
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              AppText.get(context, 'generateNewPlan'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                            .animate(delay: 520.ms)
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(.96, .96),
                              curve: Curves.easeOutBack,
                            ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _mealCard(
    BuildContext context, {
    required String title,
    required String text,
    required int calories,
    required int delay,
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

          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: calories),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue ${AppText.get(context, 'kcal')}",
                style: theme.textTheme.bodyMedium,
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 450.ms)
        .slideY(
          begin: .18,
          curve: Curves.easeOutCubic,
        );
  }
}