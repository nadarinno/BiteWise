

import 'dart:io';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/nutrition_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'result.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (!context.mounted) return;
    if (image == null) return;

    final file = File(image.path);

    final mealType = await _selectMealType(context);

    if (!context.mounted) return;
    if (mealType == null) return;

    final languageCode =
        context.read<LanguageViewModel>().locale.languageCode;

    await context.read<NutritionViewModel>().analyzeImage(
          file,
          mealType: mealType,
          languageCode: languageCode,
        );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
      ),
    );
  }

  Future<String?> _selectMealType(BuildContext context) async {
    final theme = Theme.of(context);

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppText.get(sheetContext, 'selectMealType'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _mealOption(
                sheetContext,
                title: AppText.get(sheetContext, 'breakfast'),
                icon: Icons.wb_sunny,
                value: "breakfast",
              ),
              _mealOption(
                sheetContext,
                title: AppText.get(sheetContext, 'lunch'),
                icon: Icons.lunch_dining,
                value: "lunch",
              ),
              _mealOption(
                sheetContext,
                title: AppText.get(sheetContext, 'dinner'),
                icon: Icons.dinner_dining,
                value: "dinner",
              ),
              _mealOption(
                sheetContext,
                title: AppText.get(sheetContext, 'snack'),
                icon: Icons.apple,
                value: "snack",
              ),
              const SizedBox(height: 40),
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
          AppText.get(context, 'foodScanner'),
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
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.fastfood,
                        size: 70,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () {
                              _pickImage(
                                context,
                                ImageSource.camera,
                              );
                            },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        AppText.get(context, 'takePhoto'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () {
                              _pickImage(
                                context,
                                ImageSource.gallery,
                              );
                            },
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        AppText.get(context, 'uploadFromGallery'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          56,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}