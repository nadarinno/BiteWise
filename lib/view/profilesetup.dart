import 'package:bitewise/view/home.dart';
import 'package:bitewise/utils/app_text.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                AppText.get(context, 'setupProfile'),
                style: theme.textTheme.headlineMedium,
              ).animate().fadeIn(duration: 450.ms).slideY(begin: .2),

              const SizedBox(height: 8),

              Text(
                AppText.get(context, 'profileSetupSubtitle'),
                style: theme.textTheme.bodyMedium,
              ).animate(delay: 100.ms).fadeIn().slideY(begin: .2),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _input(
                      context,
                      nameController,
                      AppText.get(context, 'name'),
                      Icons.person,
                    ).animate(delay: 180.ms).fadeIn().slideX(begin: -.12),

                    _input(
                      context,
                      ageController,
                      AppText.get(context, 'age'),
                      Icons.cake,
                      isNumber: true,
                    ).animate(delay: 240.ms).fadeIn().slideX(begin: .12),

                    _input(
                      context,
                      heightController,
                      AppText.get(context, 'heightCm'),
                      Icons.height,
                      isNumber: true,
                    ).animate(delay: 300.ms).fadeIn().slideX(begin: -.12),

                    _input(
                      context,
                      weightController,
                      AppText.get(context, 'weightKg'),
                      Icons.monitor_weight,
                      isNumber: true,
                    ).animate(delay: 360.ms).fadeIn().slideX(begin: .12),

                    _input(
                      context,
                      diseaseController,
                      AppText.get(context, 'diseaseOptional'),
                      Icons.health_and_safety,
                    ).animate(delay: 420.ms).fadeIn().slideX(begin: -.12),

                    const SizedBox(height: 20),

                    _sectionTitle(
                      context,
                      AppText.get(context, 'gender'),
                    ).animate(delay: 480.ms).fadeIn().slideY(begin: .15),

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
                    ).animate(delay: 520.ms).fadeIn().slideY(begin: .15),

                    const SizedBox(height: 20),

                    _sectionTitle(
                      context,
                      AppText.get(context, 'activityLevel'),
                    ).animate(delay: 580.ms).fadeIn().slideY(begin: .15),

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
                    ).animate(delay: 620.ms).fadeIn().slideY(begin: .15),

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
                    ).animate(delay: 680.ms).fadeIn().slideY(begin: .15),

                    const SizedBox(height: 20),

                    _sectionTitle(
                      context,
                      AppText.get(context, 'yourGoal'),
                    ).animate(delay: 740.ms).fadeIn().slideY(begin: .15),

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
                    ).animate(delay: 780.ms).fadeIn().slideY(begin: .15),
                  ],
                ),
              ).animate(delay: 140.ms).fadeIn(duration: 500.ms).scale(
                    begin: const Offset(.97, .97),
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 30),

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
                        ? const Center(
                            key: ValueKey("loading"),
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            key: const ValueKey("button"),
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.trim().isEmpty ||
                                    ageController.text.trim().isEmpty ||
                                    heightController.text.trim().isEmpty ||
                                    weightController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppText.get(
                                          context,
                                          'fillRequiredFields',
                                        ),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final success = await vm.saveProfile(
                                    name: nameController.text.trim(),
                                    age: int.parse(ageController.text.trim()),
                                    height: double.parse(
                                      heightController.text.trim(),
                                    ),
                                    weight: double.parse(
                                      weightController.text.trim(),
                                    ),
                                    gender: selectedGender,
                                    activityLevel: selectedActivityLevel,
                                    disease: diseaseController.text.trim(),
                                    goal: selectedGoal,
                                  );

                                  if (!mounted) return;

                                  if (success) {
                                    Navigator.pushReplacement(
                                      context,
                                      _fadeSlideRoute(const HomeScreen()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppText.get(
                                            context,
                                            'somethingWentWrong',
                                          ),
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
                              },
                              child: Text(
                                AppText.get(context, 'continueText'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ).animate(delay: 860.ms).fadeIn().scale(
                    begin: const Offset(.96, .96),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: theme.textTheme.titleMedium,
      ),
    );
  }

  Widget _goalButton(BuildContext context, String text, String value) {
    final theme = Theme.of(context);
    final isSelected = selectedGoal == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGoal = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : theme.dividerColor,
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionButton({
    required BuildContext context,
    required String text,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == value;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : theme.dividerColor,
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              child: Text(text),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}