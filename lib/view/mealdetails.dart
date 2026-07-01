
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

    final food = meal["food"] ?? AppText.get(context, 'meal');
    final imageUrl = meal["image"];
    final mealType = meal["mealType"] ?? "meal";
    final calories = meal["calories"] ?? 0;
    final protein = meal["protein"] ?? 0;
    final carbs = meal["carbs"] ?? 0;
    final fats = meal["fats"] ?? 0;
    final fiber = meal["fiber"] ?? 0;
    final date = meal["date"];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.get(context, 'mealDetails'),
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            tooltip: AppText.get(context, 'delete'),
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await vm.deleteMeal(docId);

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: vm.isLoading
            ? const Center(
                key: ValueKey("loading"),
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                key: const ValueKey("content"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _mealImage(context, imageUrl)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -.08),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatMealType(context, mealType),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideX(begin: -.12),

                          const SizedBox(height: 10),

                          Text(
                            food.toString(),
                            style: theme.textTheme.headlineMedium,
                          ).animate(delay: 160.ms).fadeIn().slideY(begin: .12),

                          const SizedBox(height: 30),

                          Text(
                            AppText.get(context, 'nutritionFacts'),
                            style: theme.textTheme.titleLarge,
                          ).animate(delay: 220.ms).fadeIn(),

                          Divider(
                            height: 30,
                            color: theme.dividerColor,
                          ).animate(delay: 260.ms).fadeIn(),

                          _caloriesRow(context, "$calories kcal")
                              .animate(delay: 300.ms)
                              .fadeIn()
                              .slideX(begin: -.1),

                          _detailRow(
                            context,
                            AppText.get(context, 'protein'),
                            "${protein}g",
                          ).animate(delay: 360.ms).fadeIn().slideX(begin: .1),

                          _detailRow(
                            context,
                            AppText.get(context, 'carbs'),
                            "${carbs}g",
                          ).animate(delay: 420.ms).fadeIn().slideX(begin: -.1),

                          _detailRow(
                            context,
                            AppText.get(context, 'fats'),
                            "${fats}g",
                          ).animate(delay: 480.ms).fadeIn().slideX(begin: .1),

                          _detailRow(
                            context,
                            AppText.get(context, 'fiber'),
                            "${fiber}g",
                          ).animate(delay: 540.ms).fadeIn().slideX(begin: -.1),

                          const SizedBox(height: 30),

                          Text(
                            AppText.get(context, 'date'),
                            style: theme.textTheme.titleLarge,
                          ).animate(delay: 600.ms).fadeIn(),

                          Divider(
                            height: 30,
                            color: theme.dividerColor,
                          ).animate(delay: 640.ms).fadeIn(),

                          Text(
                            _formatDate(context, date),
                            style: theme.textTheme.bodyLarge,
                          ).animate(delay: 680.ms).fadeIn().slideY(begin: .12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _mealImage(BuildContext context, dynamic imageUrl) {
    final theme = Theme.of(context);

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: 260,
        color: theme.colorScheme.surface,
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: theme.textTheme.bodyMedium?.color,
        ).animate().scale(
              duration: 450.ms,
              curve: Curves.easeOutBack,
            ),
      );
    }

    return Image.network(
      imageUrl.toString(),
      width: double.infinity,
      height: 260,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: double.infinity,
          height: 260,
          color: theme.colorScheme.surface,
          child: Icon(
            Icons.broken_image,
            size: 80,
            color: theme.textTheme.bodyMedium?.color,
          ).animate().scale(
                duration: 450.ms,
                curve: Curves.easeOutBack,
              ),
        );
      },
    );
  }

  Widget _caloriesRow(BuildContext context, String value) {
    final theme = Theme.of(context);

    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 22,
          ).animate().scale(
                duration: 350.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(width: 8),
          Text(
            AppText.get(context, 'calories'),
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: number),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue ${AppText.get(context, 'kcal')}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: number),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue${value.contains("g") ? "g" : ""}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatMealType(BuildContext context, String mealType) {
    if (mealType == "breakfast") return "${AppText.get(context, 'breakfast')} 🍳";
    if (mealType == "lunch") return "${AppText.get(context, 'lunch')} 🍗";
    if (mealType == "dinner") return "${AppText.get(context, 'dinner')} 🍲";
    if (mealType == "snack") return "${AppText.get(context, 'snack')} 🍎";
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
}