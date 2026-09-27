

import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/view/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../viewmodel/profile_view_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final diseaseController = TextEditingController();

  String selectedGender = "female";
  String selectedActivityLevel = "sedentary";
  String selectedGoal = "maintain";

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    diseaseController.dispose();
    super.dispose();
  }

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

  Future<void> _saveProfile(ProfileViewModel vm) async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        heightController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText.get(context, 'fillRequiredFields'),
          ),
        ),
      );
      return;
    }

    try {
      final success = await vm.saveProfile(
        name: nameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        height: double.parse(heightController.text.trim()),
        weight: double.parse(weightController.text.trim()),
        gender: selectedGender,
        activityLevel: selectedActivityLevel,
        disease: diseaseController.text.trim(),
        goal: selectedGoal,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          _fadeSlideRoute(const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppText.get(context, 'somethingWentWrong'),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppText.get(context, 'error')}: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context)
                        .animate()
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: .2),

                    const SizedBox(height: 24),

                    _glassBox(
                      context: context,
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        children: [
                          _input(
                            context,
                            nameController,
                            AppText.get(context, 'name'),
                            Icons.person_outline_rounded,
                          ).animate(delay: 120.ms).fadeIn().slideX(begin: -.12),

                          _input(
                            context,
                            ageController,
                            AppText.get(context, 'age'),
                            Icons.cake_outlined,
                            isNumber: true,
                          ).animate(delay: 180.ms).fadeIn().slideX(begin: .12),

                          _input(
                            context,
                            heightController,
                            AppText.get(context, 'heightCm'),
                            Icons.height_rounded,
                            isNumber: true,
                          ).animate(delay: 240.ms).fadeIn().slideX(begin: -.12),

                          _input(
                            context,
                            weightController,
                            AppText.get(context, 'weightKg'),
                            Icons.monitor_weight_outlined,
                            isNumber: true,
                          ).animate(delay: 300.ms).fadeIn().slideX(begin: .12),

                          _input(
                            context,
                            diseaseController,
                            AppText.get(context, 'diseaseOptional'),
                            Icons.medical_information_outlined,
                          ).animate(delay: 360.ms).fadeIn().slideX(begin: -.12),

                          const SizedBox(height: 20),

                          _sectionTitle(
                            context,
                            AppText.get(context, 'gender'),
                          ).animate(delay: 420.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'female'),
                                value: "female",
                                selectedValue: selectedGender,
                                onTap: () {
                                  setState(() {
                                    selectedGender = "female";
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'male'),
                                value: "male",
                                selectedValue: selectedGender,
                                onTap: () {
                                  setState(() {
                                    selectedGender = "male";
                                  });
                                },
                              ),
                            ],
                          ).animate(delay: 460.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 20),

                          _sectionTitle(
                            context,
                            AppText.get(context, 'activityLevel'),
                          ).animate(delay: 520.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'sedentary'),
                                value: "sedentary",
                                selectedValue: selectedActivityLevel,
                                onTap: () {
                                  setState(() {
                                    selectedActivityLevel = "sedentary";
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'light'),
                                value: "light",
                                selectedValue: selectedActivityLevel,
                                onTap: () {
                                  setState(() {
                                    selectedActivityLevel = "light";
                                  });
                                },
                              ),
                            ],
                          ).animate(delay: 560.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'moderate'),
                                value: "moderate",
                                selectedValue: selectedActivityLevel,
                                onTap: () {
                                  setState(() {
                                    selectedActivityLevel = "moderate";
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              _optionButton(
                                context: context,
                                text: AppText.get(context, 'veryActive'),
                                value: "very_active",
                                selectedValue: selectedActivityLevel,
                                onTap: () {
                                  setState(() {
                                    selectedActivityLevel = "very_active";
                                  });
                                },
                              ),
                            ],
                          ).animate(delay: 620.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 20),

                          _sectionTitle(
                            context,
                            AppText.get(context, 'yourGoal'),
                          ).animate(delay: 680.ms).fadeIn().slideY(begin: .15),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _goalButton(
                                context,
                                AppText.get(context, 'lose'),
                                "lose",
                              ),
                              const SizedBox(width: 10),
                              _goalButton(
                                context,
                                AppText.get(context, 'maintain'),
                                "maintain",
                              ),
                              const SizedBox(width: 10),
                              _goalButton(
                                context,
                                AppText.get(context, 'gain'),
                                "gain",
                              ),
                            ],
                          ).animate(delay: 720.ms).fadeIn().slideY(begin: .15),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).scale(
                          begin: const Offset(.97, .97),
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 26),

                    Consumer<ProfileViewModel>(
                      builder: (context, vm, _) {
                        return AnimatedSwitcher(
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
                          child: vm.isLoading
                              ? Center(
                                  key: const ValueKey("loading"),
                                  child: _glassBox(
                                    context: context,
                                    padding: const EdgeInsets.all(22),
                                    borderRadius: BorderRadius.circular(26),
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : _glassActionButton(
                                  key: const ValueKey("button"),
                                  context: context,
                                  text: AppText.get(context, 'continueText'),
                                  icon: Icons.arrow_forward_rounded,
                                  onTap: () {
                                    _saveProfile(vm);
                                  },
                                ),
                        );
                      },
                    ).animate(delay: 780.ms).fadeIn().scale(
                          begin: const Offset(.96, .96),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);

    return _glassBox(
      context: context,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.36),
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: theme.colorScheme.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get(context, 'setupProfile'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppText.get(context, 'profileSetupSubtitle'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.64),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _goalButton(BuildContext context, String text, String value) {
    final isSelected = selectedGoal == value;

    return _selectableButton(
      context: context,
      text: text,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          selectedGoal = value;
        });
      },
    );
  }

  Widget _optionButton({
    required BuildContext context,
    required String text,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;

    return _selectableButton(
      context: context,
      text: text,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _selectableButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(
                        isDark ? 0.32 : 0.22,
                      )
                    : Colors.white.withOpacity(isDark ? 0.07 : 0.34),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.70)
                      : Colors.white.withOpacity(isDark ? 0.14 : 0.50),
                  width: 1.1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.16),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            cursorColor: theme.colorScheme.primary,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: theme.colorScheme.primary.withOpacity(0.85),
                size: 22,
              ),
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.48),
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.075)
                  : Colors.white.withOpacity(0.46),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(isDark ? 0.15 : 0.55),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(isDark ? 0.15 : 0.55),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.75),
                  width: 1.7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassActionButton({
    Key? key,
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      key: key,
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
                Text(
                  text,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 23,
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