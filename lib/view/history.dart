

import 'dart:ui';

import 'package:bitewise/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bitewise/utils/app_text.dart';

import 'mealdetails.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Route _fadeSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
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
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .collection("meals")
                          .orderBy("date", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: _glassBox(
                              context: context,
                              padding: const EdgeInsets.all(22),
                              borderRadius: BorderRadius.circular(26),
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _glassBox(
                                context: context,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 34,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 54,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppText.get(context, 'noMealsYet'),
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: .15),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 115),
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final meal = docs[i].data();
                            final docId = docs[i].id;

                            return _mealBox(context, meal, docId, i);
                          },
                        );
                      },
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
              Icons.history_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              AppText.get(context, 'mealHistory'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealBox(
    BuildContext context,
    Map<String, dynamic> meal,
    String docId,
    int index,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    final food = meal["food"] ?? AppText.get(context, 'food');
    final calories = _toInt(meal["calories"]);
    final protein = _toInt(meal["protein"]);
    final carbs = _toInt(meal["carbs"]);
    final fats = _toInt(meal["fats"]);
    final mealType = meal["mealType"] ?? "meal";
    final imageUrl = meal["image"];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          _fadeSlideRoute(
            MealDetailsScreen(
              meal: meal,
              docId: docId,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(24),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mealImage(context, imageUrl)
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(
                      begin: const Offset(.9, .9),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _mealTypeChip(context, mealType),

                      const SizedBox(height: 8),

                      Text(
                        food.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: calories),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedValue, child) {
                          return Text(
                            "$animatedValue ${AppText.get(context, 'kcal')}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _macroChip(
                            context,
                            label: AppText.get(context, 'protein'),
                            value: protein,
                          ),
                          _macroChip(
                            context,
                            label: AppText.get(context, 'carbs'),
                            value: carbs,
                          ),
                          _macroChip(
                            context,
                            label: AppText.get(context, 'fats'),
                            value: fats,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  isArabic ? Icons.chevron_left : Icons.chevron_right,
                  color: theme.colorScheme.primary,
                  size: 28,
                ).animate().fadeIn(duration: 350.ms).slideX(begin: -.15),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 70 * index))
        .fadeIn(duration: 420.ms)
        .slideY(
          begin: .18,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _mealTypeChip(BuildContext context, dynamic mealType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _macroChip(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.06 : 0.30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.12 : 0.42),
        ),
      ),
      child: Text(
        "$label: ${value}g",
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.74),
        ),
      ),
    );
  }

  Widget _mealImage(BuildContext context, dynamic imageUrl) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDark ? 0.07 : 0.34),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.14 : 0.50),
            width: 1.1,
          ),
        ),
        child: Icon(
          Icons.restaurant_rounded,
          color: theme.colorScheme.primary,
          size: 34,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.14 : 0.50),
            width: 1.1,
          ),
        ),
        child: Image.network(
          imageUrl.toString(),
          width: 82,
          height: 82,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.07 : 0.34),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.broken_image_rounded,
                color: theme.colorScheme.primary,
                size: 34,
              ),
            );
          },
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

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.round();

    return int.tryParse(value.toString()) ?? 0;
  }
}