import 'dart:io';
import 'package:bitewise/view/deleteaccount.dart';
import 'package:bitewise/view/login.dart';
import 'package:bitewise/viewmodel/auth_view_model.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/setting_view_model.dart';
import 'package:bitewise/viewmodel/theme_view_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => LoginScreen(),
    ),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SettingsViewModel>();
    context.read<ThemeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
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
            ),

            const SizedBox(height: 24),

            _input(context, name, "Name"),
            _input(context, age, "Age", isNumber: true),
            _input(context, height, "Height (cm)", isNumber: true),
            _input(context, weight, "Weight (kg)", isNumber: true),
            _input(context, disease, "Disease (optional)"),

            const SizedBox(height: 20),

            _sectionTitle(context, "Gender"),
            Row(
              children: [
                _optionButton(
                  context: context,
                  text: "Female",
                  value: "female",
                  selectedValue: selectedGender,
                  onTap: () => setState(() => selectedGender = "female"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: "Male",
                  value: "male",
                  selectedValue: selectedGender,
                  onTap: () => setState(() => selectedGender = "male"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle(context, "Activity Level"),
            Row(
              children: [
                _optionButton(
                  context: context,
                  text: "Sedentary",
                  value: "sedentary",
                  selectedValue: selectedActivityLevel,
                  onTap: () =>
                      setState(() => selectedActivityLevel = "sedentary"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: "Light",
                  value: "light",
                  selectedValue: selectedActivityLevel,
                  onTap: () => setState(() => selectedActivityLevel = "light"),
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
                  onTap: () =>
                      setState(() => selectedActivityLevel = "moderate"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: "Very Active",
                  value: "very_active",
                  selectedValue: selectedActivityLevel,
                  onTap: () =>
                      setState(() => selectedActivityLevel = "very_active"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle(context, "Goal"),
            Row(
              children: [
                _optionButton(
                  context: context,
                  text: "Lose",
                  value: "lose",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "lose"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: "Maintain",
                  value: "maintain",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "maintain"),
                ),
                const SizedBox(width: 10),
                _optionButton(
                  context: context,
                  text: "Gain",
                  value: "gain",
                  selectedValue: selectedGoal,
                  onTap: () => setState(() => selectedGoal = "gain"),
                ),
              ],
            ),

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
      child: 
      SwitchListTile(
  title: const Text("Dark Mode"),
  value: themeVm.isDark,
  onChanged: (value) {
    themeVm.setTheme(value);
  },
)
    );
  },
),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
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
                  const SnackBar(content: Text("Updated")),
                );

                Navigator.pop(context);
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.dividerColor),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteAccountScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
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
        child: Container(
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
