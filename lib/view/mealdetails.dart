import 'package:bitewise/viewmodel/meal_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

    final food = meal["food"] ?? "Meal";
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
          "Meal Details",
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await vm.deleteMeal(docId);

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mealImage(context, imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatMealType(mealType),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          food,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Nutrition Facts",
                          style: theme.textTheme.titleLarge,
                        ),
                        Divider(
                          height: 30,
                          color: theme.dividerColor,
                        ),
                        _caloriesRow(context, "$calories kcal"),
                        _detailRow(context, "Protein", "${protein}g"),
                        _detailRow(context, "Carbs", "${carbs}g"),
                        _detailRow(context, "Fats", "${fats}g"),
                        _detailRow(context, "Fiber", "${fiber}g"),
                        const SizedBox(height: 30),
                        Text(
                          "Date",
                          style: theme.textTheme.titleLarge,
                        ),
                        Divider(
                          height: 30,
                          color: theme.dividerColor,
                        ),
                        Text(
                          _formatDate(date),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
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
          ),
        );
      },
    );
  }

  Widget _caloriesRow(BuildContext context, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            "Calories",
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMealType(String mealType) {
    if (mealType == "breakfast") return "Breakfast 🍳";
    if (mealType == "lunch") return "Lunch 🍗";
    if (mealType == "dinner") return "Dinner 🍲";
    if (mealType == "snack") return "Snack 🍎";
    return "Meal";
  }

  String _formatDate(dynamic date) {
    if (date == null) return "No date";

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