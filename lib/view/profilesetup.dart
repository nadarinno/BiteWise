
import 'package:bitewise/view/home.dart';
import 'package:flutter/material.dart';
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
                "Setup Your Profile 🚀",
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                "We need some info to personalize your AI coach",
                style: theme.textTheme.bodyMedium,
              ),

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
                    _input(context, nameController, "Name", Icons.person),
                    _input(context, ageController, "Age", Icons.cake, isNumber: true),
                    _input(context, heightController, "Height (cm)", Icons.height, isNumber: true),
                    _input(context, weightController, "Weight (kg)", Icons.monitor_weight, isNumber: true),
                    _input(context, diseaseController, "Disease (optional)", Icons.health_and_safety),

                    const SizedBox(height: 20),

                    _sectionTitle(context, "Gender"),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _optionButton(
                          context: context,
                          text: "Female",
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
                          text: "Male",
                          value: "male",
                          selectedValue: selectedGender,
                          onTap: () {
                            setState(() {
                              selectedGender = "male";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle(context, "Activity Level"),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _optionButton(
                          context: context,
                          text: "Sedentary",
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
                          text: "Light",
                          value: "light",
                          selectedValue: selectedActivityLevel,
                          onTap: () {
                            setState(() {
                              selectedActivityLevel = "light";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _optionButton(
                          context: context,
                          text: "Moderate",
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
                          text: "Very Active",
                          value: "very_active",
                          selectedValue: selectedActivityLevel,
                          onTap: () {
                            setState(() {
                              selectedActivityLevel = "very_active";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle(context, "Your Goal"),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _goalButton(context, "Lose", "lose"),
                        const SizedBox(width: 10),
                        _goalButton(context, "Maintain", "maintain"),
                        const SizedBox(width: 10),
                        _goalButton(context, "Gain", "gain"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Consumer<ProfileViewModel>(
                builder: (context, vm, _) {
                  return vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty ||
                                ageController.text.trim().isEmpty ||
                                heightController.text.trim().isEmpty ||
                                weightController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all required fields"),
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
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Something went wrong"),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                },
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
      alignment: Alignment.centerLeft,
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
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