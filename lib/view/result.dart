
import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
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
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: _topBar(context),
                  ),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: vm.isLoading
                          ? Center(
                              key: const ValueKey("loading"),
                              child: _glassBox(
                                context: context,
                                padding: const EdgeInsets.all(24),
                                borderRadius: BorderRadius.circular(28),
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : vm.result == null
                              ? _emptyState(context)
                              : _buildContent(context, vm),
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

  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _glassIconButton(
          context: context,
          icon: Icons.arrow_back_rounded,
          color: theme.colorScheme.primary,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _glassBox(
            context: context,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  AppText.get(context, 'result'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                AppText.get(context, 'noData'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NutritionViewModel vm) {
    final theme = Theme.of(context);
    final data = vm.result!;
    final mealType = vm.selectedMealType ?? "unknown";

    return SingleChildScrollView(
      key: const ValueKey("content"),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _glassBox(
            context: context,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mealTypeBadge(context, mealType),

                const SizedBox(height: 14),

                Text(
                  data.food,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          _descriptionBox(context)
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1),

          const SizedBox(height: 12),

          _glassActionButton(
            context: context,
            text: AppText.get(context, 'calculateMacros'),
            icon: Icons.calculate_rounded,
            onTap: () async {
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
          )
              .animate(delay: 150.ms)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 16),

          _glassBox(
            context: context,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  context,
                  title: AppText.get(context, 'nutritionSummary'),
                  icon: Icons.pie_chart_rounded,
                ),

                const SizedBox(height: 18),

                Center(
                  child: TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: data.calories),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        "$animatedValue ${AppText.get(context, 'kcal')}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(),

                const SizedBox(height: 22),

                _bar(
                  context,
                  AppText.get(context, 'protein'),
                  data.protein,
                  50,
                  Icons.fitness_center_rounded,
                ),
                _bar(
                  context,
                  AppText.get(context, 'carbs'),
                  data.carbs,
                  300,
                  Icons.rice_bowl_rounded,
                ),
                _bar(
                  context,
                  AppText.get(context, 'fats'),
                  data.fats,
                  70,
                  Icons.water_drop_outlined,
                ),
                _bar(
                  context,
                  AppText.get(context, 'fiber'),
                  data.fiber,
                  30,
                  Icons.grass_rounded,
                ),
              ],
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 450.ms).slideY(begin: 0.12),

          const SizedBox(height: 16),

          _infoCard(
            context,
            title: AppText.get(context, 'advice'),
            icon: Icons.lightbulb_rounded,
            text: data.advice,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(begin: -0.12),

          const SizedBox(height: 12),

          _infoCard(
            context,
            title: AppText.get(context, 'alternativeMeal'),
            icon: Icons.restaurant_rounded,
            text: data.alternative,
          ).animate(delay: 380.ms).fadeIn(duration: 400.ms).slideX(begin: 0.12),

          const SizedBox(height: 16),

          _saveButton(context, data.calories)
              .animate(delay: 450.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _descriptionBox(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: TextField(
          controller: mealDescriptionController,
          maxLines: 4,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          cursorColor: theme.colorScheme.primary,
          decoration: InputDecoration(
            hintText: AppText.get(context, 'enterMealDetails'),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.48),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.075)
                : Colors.white.withOpacity(0.46),
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.15 : 0.55),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.15 : 0.55),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.75),
                width: 1.7,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context, int calories) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: calories == 0 || _isSaving
          ? null
          : () async {
              setState(() {
                _isSaving = true;
              });

              try {
                await context.read<NutritionViewModel>().saveMeal();

                if (!context.mounted) return;

                await context.read<DashboardViewModel>().refreshAfterMealSaved();

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
      child: _glassBox(
        context: context,
        width: double.infinity,
        height: 58,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(22),
        child: Center(
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
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppText.get(context, 'saving'),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey("save"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        color: calories == 0
                            ? theme.colorScheme.onSurface.withOpacity(0.35)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppText.get(context, 'saveMeal'),
                        style: TextStyle(
                          color: calories == 0
                              ? theme.colorScheme.onSurface.withOpacity(0.35)
                              : theme.colorScheme.primary,
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

  Widget _mealTypeBadge(BuildContext context, String mealType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.24 : 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.45),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).scale();
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _rowIcon(context, icon),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return _glassBox(
      context: context,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowIcon(context, icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text.isEmpty
                      ? AppText.get(context, 'enterQuantityFirst')
                      : text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
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
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final percent = (value / goal).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _rowIcon(context, icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$name: ${value}g",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percent),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.08);
  }

  Widget _rowIcon(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.34),
        ),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 20,
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

  Widget _glassIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
                width: 1.1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
    Key? key,
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
      key: key,
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