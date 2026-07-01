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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.get(context, 'mealHistory'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("meals")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                AppText.get(context, 'noMealsYet'),
                style: theme.textTheme.bodyMedium,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: .15),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final meal = docs[i].data();
              final docId = docs[i].id;

              return _mealBox(context, meal, docId, i);
            },
          );
        },
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
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    final food = meal["food"] ?? AppText.get(context, 'food');
    final calories = meal["calories"] ?? 0;
    final protein = meal["protein"] ?? 0;
    final carbs = meal["carbs"] ?? 0;
    final fats = meal["fats"] ?? 0;
    final mealType = meal["mealType"] ?? "meal";
    final imageUrl = meal["image"];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
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
                  Text(
                    _formatMealType(context, mealType),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    food.toString(),
                    style: theme.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: calories),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        "$animatedValue ${AppText.get(context, 'kcal')}",
                        style: theme.textTheme.bodyMedium,
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${AppText.get(context, 'protein')}: ${protein}g  •  "
                    "${AppText.get(context, 'carbs')}: ${carbs}g  •  "
                    "${AppText.get(context, 'fat')}: ${fats}g",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.75,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isArabic ? Icons.chevron_left : Icons.chevron_right,
              color: theme.colorScheme.primary,
            ).animate().fadeIn(duration: 350.ms).slideX(begin: -.15),
          ],
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

  Widget _mealImage(BuildContext context, dynamic imageUrl) {
    final theme = Theme.of(context);

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(
          Icons.restaurant,
          color: theme.textTheme.bodyMedium?.color,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl.toString(),
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.broken_image,
              color: theme.textTheme.bodyMedium?.color,
              size: 32,
            ),
          );
        },
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
}