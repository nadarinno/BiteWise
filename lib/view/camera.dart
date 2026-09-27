

import 'dart:io';
import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/nutrition_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/utils/app_theme.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(isDark ? 0.55 : 0.25),
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 22,
                sigmaY: 22,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.09)
                      : Colors.white.withOpacity(0.48),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.16 : 0.58),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.32 : 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        AppText.get(sheetContext, 'selectMealType'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _mealOption(
                        sheetContext,
                        title: AppText.get(sheetContext, 'breakfast'),
                        icon: Icons.wb_sunny_rounded,
                        value: "breakfast",
                      ),
                      const SizedBox(height: 10),
                      _mealOption(
                        sheetContext,
                        title: AppText.get(sheetContext, 'lunch'),
                        icon: Icons.lunch_dining_rounded,
                        value: "lunch",
                      ),
                      const SizedBox(height: 10),
                      _mealOption(
                        sheetContext,
                        title: AppText.get(sheetContext, 'dinner'),
                        icon: Icons.dinner_dining_rounded,
                        value: "dinner",
                      ),
                      const SizedBox(height: 10),
                      _mealOption(
                        sheetContext,
                        title: AppText.get(sheetContext, 'snack'),
                        icon: Icons.apple_rounded,
                        value: "snack",
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, value);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.07 : 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.14 : 0.50),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(
                      isDark ? 0.22 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
              child: vm.isLoading
                  ? Center(
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
                              AppText.get(context, 'analyzing'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 115),
                      child: Column(
                        children: [
                          _topTitle(context),

                          const Spacer(),

                          _mainScannerCard(context),

                          const SizedBox(height: 28),

                          _actionButton(
                            context: context,
                            text: AppText.get(context, 'takePhoto'),
                            icon: Icons.camera_alt_rounded,
                            isPrimary: true,
                            onTap: () {
                              _pickImage(
                                context,
                                ImageSource.camera,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          _actionButton(
                            context: context,
                            text: AppText.get(context, 'uploadFromGallery'),
                            icon: Icons.photo_library_rounded,
                            isPrimary: false,
                            onTap: () {
                              _pickImage(
                                context,
                                ImageSource.gallery,
                              );
                            },
                          ),

                          const Spacer(),
                        ],
                      ),
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
              Icons.document_scanner_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              AppText.get(context, 'foodScanner'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainScannerCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _glassBox(
      context: context,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      borderRadius: BorderRadius.circular(34),
      child: Column(
        children: [
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.07 : 0.32),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.16 : 0.56),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(
              Icons.fastfood_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            AppText.get(context, 'scanYourMeal'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppText.get(context, 'scanMealDescription'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.62),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required bool isPrimary,
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
              color: isPrimary
                  ? theme.colorScheme.primary.withOpacity(isDark ? 0.30 : 0.22)
                  : Colors.white.withOpacity(isDark ? 0.07 : 0.38),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPrimary
                    ? theme.colorScheme.primary.withOpacity(0.70)
                    : Colors.white.withOpacity(isDark ? 0.15 : 0.56),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? theme.colorScheme.primary.withOpacity(0.18)
                      : Colors.black.withOpacity(isDark ? 0.20 : 0.07),
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
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.78),
                  size: 23,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: isPrimary
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.82),
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