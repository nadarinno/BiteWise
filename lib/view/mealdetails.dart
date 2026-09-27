

import 'dart:ui';

import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/viewmodel/meal_view_model.dart';
import 'package:bitewise/utils/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class MealDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> meal;
  final String docId;

  const MealDetailsScreen({
    super.key,
    required this.meal,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final food = meal["food"] ?? AppText.get(context, 'meal');
    final imageUrl = meal["image"];
    final mealType = meal["mealType"] ?? "meal";
    final calories = _toInt(meal["calories"]);
    final protein = _toInt(meal["protein"]);
    final carbs = _toInt(meal["carbs"]);
    final fats = _toInt(meal["fats"]);
    final fiber = _toInt(meal["fiber"]);
    final date = meal["date"] ?? meal["createdAt"];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppText.get(context, 'mealDetails'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: _glassIconButton(
              context: context,
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              onTap: () async {
                await vm.deleteMeal(docId);

                if (!context.mounted) return;

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
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
                    : SingleChildScrollView(
                        key: const ValueKey("content"),
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _mealImage(context, imageUrl)
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: -.08),

                            const SizedBox(height: 18),

                            _glassBox(
                              context: context,
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              borderRadius: BorderRadius.circular(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _mealTypeChip(context, mealType),

                                  const SizedBox(height: 12),

                                  Text(
                                    food.toString(),
                                    style:
                                        theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ).animate(delay: 120.ms).fadeIn().slideY(
                                        begin: .12,
                                      ),
                                ],
                              ),
                            ).animate(delay: 100.ms).fadeIn().slideY(
                                  begin: .12,
                                ),

                            const SizedBox(height: 18),

                            _sectionCard(
                              context: context,
                              title: AppText.get(context, 'nutritionFacts'),
                              icon: Icons.analytics_outlined,
                              children: [
                                _caloriesRow(context, calories)
                                    .animate(delay: 220.ms)
                                    .fadeIn()
                                    .slideX(begin: -.1),

                                _detailRow(
                                  context,
                                  label: AppText.get(context, 'protein'),
                                  value: protein,
                                  unit: "g",
                                  icon: Icons.fitness_center_rounded,
                                ).animate(delay: 280.ms).fadeIn().slideX(
                                      begin: .1,
                                    ),

                                _detailRow(
                                  context,
                                  label: AppText.get(context, 'carbs'),
                                  value: carbs,
                                  unit: "g",
                                  icon: Icons.rice_bowl_rounded,
                                ).animate(delay: 340.ms).fadeIn().slideX(
                                      begin: -.1,
                                    ),

                                _detailRow(
                                  context,
                                  label: AppText.get(context, 'fats'),
                                  value: fats,
                                  unit: "g",
                                  icon: Icons.water_drop_outlined,
                                ).animate(delay: 400.ms).fadeIn().slideX(
                                      begin: .1,
                                    ),

                                _detailRow(
                                  context,
                                  label: AppText.get(context, 'fiber'),
                                  value: fiber,
                                  unit: "g",
                                  icon: Icons.grass_rounded,
                                ).animate(delay: 460.ms).fadeIn().slideX(
                                      begin: -.1,
                                    ),
                              ],
                            ).animate(delay: 180.ms).fadeIn().slideY(
                                  begin: .14,
                                ),

                            const SizedBox(height: 18),

                            _sectionCard(
                              context: context,
                              title: AppText.get(context, 'date'),
                              icon: Icons.calendar_month_rounded,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _formatDate(context, date),
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).animate(delay: 520.ms).fadeIn().slideY(
                                  begin: .14,
                                ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealImage(BuildContext context, dynamic imageUrl) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return _glassBox(
        context: context,
        width: double.infinity,
        height: 260,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(34),
        child: Center(
          child: Icon(
            Icons.restaurant_rounded,
            size: 82,
            color: theme.colorScheme.primary,
          ).animate().scale(
                duration: 450.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.42),
            borderRadius: BorderRadius.circular(34),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 82,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return _glassBox(
      context: context,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: Colors.white.withOpacity(
              theme.brightness == Brightness.dark ? 0.12 : 0.45,
            ),
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }

  Widget _caloriesRow(BuildContext context, int calories) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _rowIcon(context, Icons.local_fire_department_rounded),
          const SizedBox(width: 10),
          Text(
            AppText.get(context, 'calories'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: calories),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue ${AppText.get(context, 'kcal')}",
                style: theme.textTheme.bodyLarge?.copyWith(
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

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required int value,
    required String unit,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _rowIcon(context, icon),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue$unit",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _rowIcon(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(13),
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

  Widget _mealTypeChip(BuildContext context, dynamic mealType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        _formatMealType(context, mealType.toString()),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
                width: 1.1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
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

  String _formatMealType(BuildContext context, String mealType) {
    if (mealType == "breakfast") {
      return "${AppText.get(context, 'breakfast')} 🍳";
    }

    if (mealType == "lunch") {
      return "${AppText.get(context, 'lunch')} 🍗";
    }

    if (mealType == "dinner") {
      return "${AppText.get(context, 'dinner')} 🍲";
    }

    if (mealType == "snack") {
      return "${AppText.get(context, 'snack')} 🍎";
    }

    return AppText.get(context, 'meal');
  }

  String _formatDate(BuildContext context, dynamic date) {
    if (date == null) return AppText.get(context, 'noDate');

    DateTime dateTime;

    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return date.toString();
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return "$day/$month/$year  $hour:$minute";
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.round();

    return int.tryParse(value.toString()) ?? 0;
  }
}