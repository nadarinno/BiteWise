

import 'dart:io';
import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/view/deleteaccount.dart';
import 'package:bitewise/view/login.dart';
import 'package:bitewise/viewmodel/auth_view_model.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/setting_view_model.dart';
import 'package:bitewise/viewmodel/theme_view_model.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppText.get(context, 'settings'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
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
              top: 180,
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                      child: _glassBox(
                        context: context,
                        width: 108,
                        height: 108,
                        padding: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(36),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor:
                              Colors.white.withOpacity(isDark ? 0.08 : 0.35),
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
                    ).animate().fadeIn(duration: 450.ms).scale(
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 24),

                    _input(
                      context,
                      name,
                      AppText.get(context, 'name'),
                      icon: Icons.person_outline_rounded,
                    ).animate(delay: 80.ms).fadeIn().slideX(begin: -.12),

                    _input(
                      context,
                      age,
                      AppText.get(context, 'age'),
                      icon: Icons.cake_outlined,
                      isNumber: true,
                    ).animate(delay: 140.ms).fadeIn().slideX(begin: .12),

                    _input(
                      context,
                      height,
                      AppText.get(context, 'heightCm'),
                      icon: Icons.height_rounded,
                      isNumber: true,
                    ).animate(delay: 200.ms).fadeIn().slideX(begin: -.12),

                    _input(
                      context,
                      weight,
                      AppText.get(context, 'weightKg'),
                      icon: Icons.monitor_weight_outlined,
                      isNumber: true,
                    ).animate(delay: 260.ms).fadeIn().slideX(begin: .12),

                    _input(
                      context,
                      disease,
                      AppText.get(context, 'diseaseOptional'),
                      icon: Icons.medical_information_outlined,
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
                          onTap: () => setState(
                            () => selectedActivityLevel = "sedentary",
                          ),
                        ),
                        const SizedBox(width: 10),
                        _optionButton(
                          context: context,
                          text: AppText.get(context, 'light'),
                          value: "light",
                          selectedValue: selectedActivityLevel,
                          onTap: () => setState(
                            () => selectedActivityLevel = "light",
                          ),
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
                          onTap: () => setState(
                            () => selectedActivityLevel = "moderate",
                          ),
                        ),
                        const SizedBox(width: 10),
                        _optionButton(
                          context: context,
                          text: AppText.get(context, 'veryActive'),
                          value: "very_active",
                          selectedValue: selectedActivityLevel,
                          onTap: () => setState(
                            () => selectedActivityLevel = "very_active",
                          ),
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
                          onTap: () => setState(
                            () => selectedGoal = "maintain",
                          ),
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
                        return _glassBox(
                          context: context,
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(22),
                          child: SwitchListTile(
                            title: Text(
                              AppText.get(context, 'darkMode'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            secondary: Icon(
                              themeVm.isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            value: themeVm.isDark,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (value) {
                              themeVm.setTheme(value);
                            },
                          ),
                        );
                      },
                    ).animate(delay: 740.ms).fadeIn().slideY(begin: .15),

                    const SizedBox(height: 16),

                    _languageSwitcherCard(context)
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

                    _glassActionButton(
                      context: context,
                      text: AppText.get(context, 'logout'),
                      onPressed: _logout,
                      icon: Icons.logout_rounded,
                    ).animate(delay: 920.ms).fadeIn().slideY(begin: .15),

                    const SizedBox(height: 16),

                    _glassActionButton(
                      context: context,
                      text: AppText.get(context, 'deleteAccount'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          _fadeSlideRoute(const DeleteAccountScreen()),
                        );
                      },
                      icon: Icons.delete_outline_rounded,
                      isDanger: true,
                    ).animate(delay: 980.ms).fadeIn().slideY(begin: .15),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController c,
    String hint, {
    required IconData icon,
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
            controller: c,
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

  Widget _optionButton({
    required BuildContext context,
    required String text,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedValue == value;

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

  Widget _languageSwitcherCard(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<LanguageViewModel>(
      builder: (context, languageVm, child) {
        final currentLanguage = languageVm.locale.languageCode;

        return _glassBox(
          context: context,
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                  bottom: 10,
                  top: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 21,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppText.get(context, 'language'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    _languageOption(
                      context: context,
                      text: "English",
                      value: "en",
                      selectedValue: currentLanguage,
                      onTap: () {
                        languageVm.changeLanguage("en");
                      },
                    ),
                    const SizedBox(width: 8),
                    _languageOption(
                      context: context,
                      text: "العربية",
                      value: "ar",
                      selectedValue: currentLanguage,
                      onTap: () {
                        languageVm.changeLanguage("ar");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required BuildContext context,
    required String text,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.30 : 0.20)
                : Colors.white.withOpacity(isDark ? 0.05 : 0.24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.75)
                  : Colors.white.withOpacity(isDark ? 0.10 : 0.40),
              width: 1.1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.72),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassActionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isDanger = false,
  }) {
    final theme = Theme.of(context);
    final color = isDanger ? Colors.red : theme.colorScheme.primary;

    return GestureDetector(
      onTap: onPressed,
      child: _glassBox(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: BorderRadius.circular(18),
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}