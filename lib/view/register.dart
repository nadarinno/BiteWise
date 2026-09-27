

import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/viewmodel/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_view_model.dart';
import 'login.dart';
import 'profilesetup.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    confirmPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppText.get(context, 'emailRequired');
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return AppText.get(context, 'validEmailRequired');
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppText.get(context, 'passwordRequired');
    }

    if (value.length < 8) {
      return AppText.get(context, 'passwordMinLength');
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return AppText.get(context, 'uppercaseRequired');
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return AppText.get(context, 'lowercaseRequired');
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return AppText.get(context, 'numberRequired');
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppText.get(context, 'confirmPasswordRequired');
    }

    if (value != passwordController.text) {
      return AppText.get(context, 'passwordsDoNotMatch');
    }

    return null;
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

  Future<void> _register(AuthViewModel auth) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final success = await auth.register(email, password);

    if (!context.mounted) return;

    if (success) {
      await context.read<ThemeViewModel>().setTheme(true);

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        _fadeSlideRoute(
          const ProfileSetupScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? AppText.get(context, 'registerFailed'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
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
                size: 210,
              ),
            ),
            Positioned(
              top: 190,
              right: -80,
              child: _blurCircle(
                color: Colors.purple.withOpacity(isDark ? 0.22 : 0.18),
                size: 200,
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _glassBox(
                    context: context,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    borderRadius: BorderRadius.circular(34),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                isDark ? 0.24 : 0.16,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.36),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.colorScheme.primary.withOpacity(0.18),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: theme.colorScheme.primary,
                              size: 42,
                            ),
                          ).animate().fadeIn(duration: 500.ms).scale(
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: 22),

                          Text(
                            AppText.get(context, 'createAccount'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideY(begin: .2),

                          const SizedBox(height: 8),

                          Text(
                            AppText.get(context, 'registerSubtitle'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.62),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ).animate(delay: 180.ms).fadeIn().slideY(begin: .2),

                          const SizedBox(height: 34),

                          _input(
                            context,
                            emailController,
                            AppText.get(context, 'emailAddress'),
                            Icons.email_rounded,
                            validator: validateEmail,
                          ).animate(delay: 260.ms).fadeIn().slideX(begin: -.15),

                          const SizedBox(height: 16),

                          _input(
                            context,
                            passwordController,
                            AppText.get(context, 'password'),
                            Icons.lock_rounded,
                            isPassword: true,
                            validator: validatePassword,
                          ).animate(delay: 340.ms).fadeIn().slideX(begin: .15),

                          const SizedBox(height: 16),

                          _input(
                            context,
                            confirmPasswordController,
                            AppText.get(context, 'confirmPassword'),
                            Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: validateConfirmPassword,
                          ).animate(delay: 420.ms).fadeIn().slideX(begin: -.15),

                          const SizedBox(height: 24),

                          AnimatedSwitcher(
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
                            child: auth.isLoading
                                ? _glassBox(
                                    key: const ValueKey("loading"),
                                    context: context,
                                    padding: const EdgeInsets.all(18),
                                    borderRadius: BorderRadius.circular(24),
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : _glassActionButton(
                                    key: const ValueKey("button"),
                                    context: context,
                                    text: AppText.get(context, 'createAccount'),
                                    icon: Icons.arrow_forward_rounded,
                                    onTap: () {
                                      _register(auth);
                                    },
                                  ),
                          ).animate(delay: 500.ms).fadeIn().scale(
                                begin: const Offset(.96, .96),
                              ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  AppText.get(context, 'alreadyHaveAccount'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.62),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    _fadeSlideRoute(LoginScreen()),
                                  );
                                },
                                child: Text(
                                  AppText.get(context, 'login'),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ).animate(delay: 580.ms).fadeIn().slideY(begin: .2),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(
                        begin: .12,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: TextFormField(
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          obscureText: isPassword,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          cursorColor: theme.colorScheme.primary,
          decoration: InputDecoration(
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.075)
                : Colors.white.withOpacity(0.46),
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.48),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.primary.withOpacity(0.85),
              size: 22,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.3,
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
    Key? key,
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
      key: key,
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