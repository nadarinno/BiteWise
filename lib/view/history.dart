
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mealdetails.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Meal History",
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
                "No meals yet",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final meal = docs[i].data();
              final docId = docs[i].id;

              return _mealBox(context, meal, docId);
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
  ) {
    final theme = Theme.of(context);

    final food = meal["food"] ?? "Food";
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
          MaterialPageRoute(
            builder: (_) => MealDetailsScreen(
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
            _mealImage(context, imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatMealType(mealType),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$calories kcal",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Protein: ${protein}g  •  Carbs: ${carbs}g  •  Fats: ${fats}g",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
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

  String _formatMealType(String mealType) {
    if (mealType == "breakfast") return "Breakfast 🍳";
    if (mealType == "lunch") return "Lunch 🍗";
    if (mealType == "dinner") return "Dinner 🍲";
    if (mealType == "snack") return "Snack 🍎";
    return "Meal";
  }
}