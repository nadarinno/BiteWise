
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodel/nutrition_view_model.dart';
import 'result.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image == null) return;

    final file = File(image.path);
    final mealType = await _selectMealType(context);

    if (mealType == null) return;

    await context.read<NutritionViewModel>().analyzeImage(
          file,
          mealType: mealType,
        );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  Future<String?> _selectMealType(BuildContext context) async {
    final theme = Theme.of(context);

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Meal Type",
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 20),

              _mealOption(
                context,
                title: "Breakfast",
                icon: Icons.wb_sunny,
                value: "breakfast",
              ),

              _mealOption(
                context,
                title: "Lunch",
                icon: Icons.lunch_dining,
                value: "lunch",
              ),

              _mealOption(
                context,
                title: "Dinner",
                icon: Icons.dinner_dining,
                value: "dinner",
              ),

              _mealOption(
                context,
                title: "Snack",
                icon: Icons.apple,
                value: "snack",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mealOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Food Scanner",
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        Icons.fastfood,
                        size: 70,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: () {
                        _pickImage(context, ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        "Take Photo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    OutlinedButton.icon(
                      onPressed: () {
                        _pickImage(context, ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text(
                        "Upload From Gallery",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}