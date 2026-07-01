
import 'dart:io';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/view/deleteaccount.dart';
import 'package:bitewise/view/login.dart';
import 'package:bitewise/viewmodel/auth_view_model.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/setting_view_model.dart';
import 'package:bitewise/viewmodel/theme_view_model.dart';
import 'package:bitewise/widget/language_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final name = TextEditingController();
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  final disease = TextEditingController();

  Map<String, dynamic>? data;

  String selectedGender = "female";
  String selectedActivityLevel = "sedentary";
  String selectedGoal = "maintain";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final vm = context.read<SettingsViewModel>();
    final userData = await vm.loadUser();

    if (!mounted) return;

    setState(() {
      data = userData;
      selectedGender = userData["gender"] ?? "female";
      selectedActivityLevel = userData["activityLevel"] ?? "sedentary";
      selectedGoal = userData["goal"] ?? "maintain";
    });

    name.text = userData["name"] ?? "";
    age.text = userData["age"]?.toString() ?? "";
    height.text = userData["height"]?.toString() ?? "";
    weight.text = userData["weight"]?.toString() ?? "";
    disease.text = userData["disease"] ?? "";
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    disease.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
  if (!context.mounted) return;

  context.read<LanguageViewModel>().resetToDefault();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
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

  Future<void> _saveSettings(SettingsViewModel vm) async {
    if (name.text.trim().isEmpty ||
        age.text.trim().isEmpty ||
        height.text.trim().isEmpty ||
        weight.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.get(context, 'fillRequiredFields')),
        ),
      );
      return;
    }

    try {
      await vm.updateProfile(
        name: name.text.trim(),
        age: int.parse(age.text.trim()),
        height: double.parse(height.text.trim()),
        weight: double.parse(weight.text.trim()),
        disease: disease.text.trim(),
        gender: selectedGender,
        activityLevel: selectedActivityLevel,
        goal: selectedGoal,
      );

      await context.read<DashboardViewModel>().loadDashboard();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.get(context, 'updated')),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppText.get(context, 'error')}: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.get(context, 'settings'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  await vm.updateProfileImage(File(image.path));
                  await loadData();
                }
              },
              child: CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: data?["profileImage"] != null
                    ? NetworkImage(data!["profileImage"])
                    : null,
                child: data?["profileImage"] == null
                    ? Icon(
                        Icons.person,
                        size: 42,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ).animate().fadeIn(duration: 450.ms).scale(
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 24),

            _input(context, name, AppText.get(context, 'name'))
                .animate(delay: 80.ms)
                .fadeIn()
                .slideX(begin: -.12),

            _input(
              context,
              age,
              AppText.get(context, 'age'),
              isNumber: true,
            ).animate(delay: 140.ms).fadeIn().slideX(begin: .12),

            _input(
              context,
              height,
              AppText.get(context, 'heightCm'),
              isNumber: true,
            ).animate(delay: 200.ms).fadeIn().slideX(begin: -.12),

            _input(
              context,
              weight,
              AppText.get(context, 'weightKg'),
              isNumber: true,
            ).animate(delay: 260.ms).fadeIn().slideX(begin: .12),

            _input(
              context,
              disease,
              AppText.get(context, 'diseaseOptional'),
            ).animate(delay: 320.ms).fadeIn().slideX(begin: -.12),

            const SizedBox(height: 20),

            _sectionTitle(context, AppText.get(context, 'gender'))
                .animate(delay: 380.ms)
                .fadeIn()
                .slideY(begin: .15),

            Row(
              children: [
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'female'),
                  value: "female",
                  selectedValue: selectedGender,
                  onTap: () => setState(() => selectedGender = "female"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'male'),
                  value: "male",
                  selectedValue: selectedGender,
                  onTap: () => setState(() => selectedGender = "male"),
                ),
              ],
            ).animate(delay: 420.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 20),

            _sectionTitle(context, AppText.get(context, 'activityLevel'))
                .animate(delay: 480.ms)
                .fadeIn()
                .slideY(begin: .15),

            Row(
              children: [
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'sedentary'),
                  value: "sedentary",
                  selectedValue: selectedActivityLevel,
                  onTap: () =>
                      setState(() => selectedActivityLevel = "sedentary"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'light'),
                  value: "light",
                  selectedValue: selectedActivityLevel,
                  onTap: () => setState(() => selectedActivityLevel = "light"),
                ),
              ],
            ).animate(delay: 520.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 10),

            Row(
              children: [
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'moderate'),
                  value: "moderate",
                  selectedValue: selectedActivityLevel,
                  onTap: () =>
                      setState(() => selectedActivityLevel = "moderate"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'veryActive'),
                  value: "very_active",
                  selectedValue: selectedActivityLevel,
                  onTap: () =>
                      setState(() => selectedActivityLevel = "very_active"),
                ),
              ],
            ).animate(delay: 580.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 20),

            _sectionTitle(context, AppText.get(context, 'goal'))
                .animate(delay: 640.ms)
                .fadeIn()
                .slideY(begin: .15),

            Row(
              children: [
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'lose'),
                  value: "lose",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "lose"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'maintain'),
                  value: "maintain",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "maintain"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: AppText.get(context, 'gain'),
                  value: "gain",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "gain"),
                ),
              ],
            ).animate(delay: 680.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 24),

            Consumer<ThemeViewModel>(
              builder: (context, themeVm, child) {
                final theme = Theme.of(context);

                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: SwitchListTile(
                    title: Text(AppText.get(context, 'darkMode')),
                    value: themeVm.isDark,
                    onChanged: (value) {
                      themeVm.setTheme(value);
                    },
                  ),
                );
              },
            ).animate(delay: 740.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 16),

            const LanguageSwitcher()
                .animate(delay: 800.ms)
                .fadeIn()
                .slideY(begin: .15),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _saveSettings(vm),
                child: Text(
                  AppText.get(context, 'saveChanges'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ).animate(delay: 860.ms).fadeIn().scale(
                  begin: const Offset(.96, .96),
                ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.dividerColor),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                AppText.get(context, 'logout'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate(delay: 920.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  _fadeSlideRoute(const DeleteAccountScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                AppText.get(context, 'deleteAccount'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate(delay: 980.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: theme.textTheme.titleMedium,
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
    TextEditingController c,
    String hint, {
    bool isNumber = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}