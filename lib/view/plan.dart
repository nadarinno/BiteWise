

import 'dart:ui';

import 'package:bitewise/utils/app_theme.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradientColors(isDark),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: _blurCircle(
                color: theme.colorScheme.primary.withOpacity(0.30),
                size: 200,
              ),
            ),
            Positioned(
              top: 190,
              right: -70,
              child: _blurCircle(
                color: Colors.purple.withOpacity(isDark ? 0.22 : 0.18),
                size: 190,
              ),
            ),
            Positioned(
              bottom: -90,
              left: 30,
              child: _blurCircle(
                color: Colors.cyan.withOpacity(isDark ? 0.16 : 0.22),
                size: 190,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                    child: _topTitle(context),
                  ),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: vm.isLoading
                          ? Center(
                              key: const ValueKey("loading"),
                              child: _glassBox(
                                context: context,
                                padding: const EdgeInsets.all(24),
                                borderRadius: BorderRadius.circular(28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      AppText.get(context, 'dailyPlan'),
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : vm.plan == null
                              ? _emptyState(context)
                              : SingleChildScrollView(
                                  key: const ValueKey("content"),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 10, 16, 115),
                                  child: Column(
                                    children: [
                                      _mealCard(
                                        context,
                                        title:
                                            "${AppText.get(context, 'breakfast')} 🍳",
                                        text: vm.plan!.breakfast,
                                        calories: vm.plan!.breakfastCalories,
                                        icon: Icons.wb_sunny_rounded,
                                        delay: 0,
                                      ),

                                      _mealCard(
                                        context,
                                        title:
                                            "${AppText.get(context, 'lunch')} 🍗",
                                        text: vm.plan!.lunch,
                                        calories: vm.plan!.lunchCalories,
                                        icon: Icons.lunch_dining_rounded,
                                        delay: 100,
                                      ),

                                      _mealCard(
                                        context,
                                        title:
                                            "${AppText.get(context, 'dinner')} 🍲",
                                        text: vm.plan!.dinner,
                                        calories: vm.plan!.dinnerCalories,
                                        icon: Icons.dinner_dining_rounded,
                                        delay: 200,
                                      ),

                                      _mealCard(
                                        context,
                                        title:
                                            "${AppText.get(context, 'snack')} 🍎",
                                        text: vm.plan!.snack,
                                        calories: vm.plan!.snackCalories,
                                        icon: Icons.apple_rounded,
                                        delay: 300,
                                      ),

                                      const SizedBox(height: 4),

                                      _totalCaloriesCard(
                                        context,
                                        totalCalories:
                                            vm.plan!.totalCalories,
                                      ).animate(delay: 420.ms).fadeIn(
                                            duration: 450.ms,
                                          ).slideY(begin: .15),

                                      const SizedBox(height: 20),

                                      _glassActionButton(
                                        context: context,
                                        text: AppText.get(
                                          context,
                                          'generateNewPlan',
                                        ),
                                        icon: Icons.refresh_rounded,
                                        onTap: () {
                                          _generatePlan(context);
                                        },
                                      ).animate(delay: 520.ms).fadeIn(
                                            duration: 400.ms,
                                          ).scale(
                                            begin: const Offset(.96, .96),
                                            curve: Curves.easeOutBack,
                                          ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: _glassBox(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              AppText.get(context, 'dailyPlan'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      key: const ValueKey("empty"),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _glassBox(
          context: context,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
          borderRadius: BorderRadius.circular(34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.35),
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 54,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                AppText.get(context, 'dailyPlan'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                AppText.get(context, 'generatePlan'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.64),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              _glassActionButton(
                context: context,
                text: AppText.get(context, 'generatePlan'),
                icon: Icons.restaurant_rounded,
                onTap: () {
                  _generatePlan(context);
                },
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _mealCard(
    BuildContext context, {
    required String title,
    required String text,
    required int calories,
    required IconData icon,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.16 : 0.60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _mealIcon(context, icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: calories),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(
                        isDark ? 0.22 : 0.14,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.38),
                      ),
                    ),
                    child: Text(
                      "$animatedValue ${AppText.get(context, 'kcal')}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 450.ms)
        .slideY(
          begin: .18,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _mealIcon(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.34),
        ),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _totalCaloriesCard(
    BuildContext context, {
    required int totalCalories,
  }) {
    final theme = Theme.of(context);

    return _glassBox(
      context: context,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      child: Row(
        children: [
          _mealIcon(
            context,
            Icons.local_fire_department_rounded,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppText.get(context, 'total'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(
              begin: 0,
              end: totalCalories,
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue ${AppText.get(context, 'kcal')}",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glassActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(
                isDark ? 0.30 : 0.22,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.70),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 23,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _blurCircle({
    required Color color,
    required double size,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 45,
        sigmaY: 45,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _glassBox({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    BorderRadius? borderRadius,
    double? width,
    double? height,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final radius = borderRadius ?? BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.42),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.16 : 0.60),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}