

import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/view/main_navigation_screen.dart';
import 'package:bitewise/viewmodel/language_view_model.dart';
import 'package:bitewise/viewmodel/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_view_model.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? passwordServerError;
  String? emailServerError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppText.get(context, 'emailRequired');
    }

    final emailRegex = RegExp(r'^[\w\.-]+@gmail\.com$');

    if (!emailRegex.hasMatch(value.trim())) {
      return AppText.get(context, 'validGmailRequired');
    }

    return emailServerError;
  }

  String? validateResetEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppText.get(context, 'emailRequired');
    }

    final emailRegex = RegExp(r'^[\w\.-]+@gmail\.com$');

    if (!emailRegex.hasMatch(value.trim())) {
      return AppText.get(context, 'validGmailRequired');
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppText.get(context, 'passwordRequired');
    }

    if (value.trim().length < 8) {
      return AppText.get(context, 'passwordMinLength');
    }

    return passwordServerError;
  }

  void showResetDialog(BuildContext context) {
    final resetEmail = TextEditingController();
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: _glassBox(
            context: dialogContext,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            borderRadius: BorderRadius.circular(28),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _smallIconBox(
                        dialogContext,
                        Icons.lock_reset_rounded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.get(context, 'resetPassword'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _input(
                    dialogContext,
                    resetEmail,
                    AppText.get(context, 'enterYourEmail'),
                    Icons.email_outlined,
                    validator: validateResetEmail,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _secondaryGlassButton(
                          context: dialogContext,
                          text: AppText.get(context, 'cancel'),
                          onTap: () {
                            Navigator.pop(dialogContext);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _primaryGlassButton(
                          context: dialogContext,
                          text: AppText.get(context, 'send'),
                          icon: Icons.send_rounded,
                          onTap: () async {
                            if (!formKey.currentState!.validate()) return;

                            try {
                              await auth.forgotPassword(
                                resetEmail.text.trim(),
                              );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppText.get(
                                      context,
                                      'passwordResetSent',
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!dialogContext.mounted) return;

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
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).scale(
                begin: const Offset(0.92, 0.92),
                curve: Curves.easeOutBack,
              ),
        );
      },
    ).then((_) {
      resetEmail.dispose();
    });
  }

  Route _homeRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) {
        return const MainNavigationScreen();
      },
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.08, 0),
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

  Route _registerRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) {
        return const RegisterScreen();
      },
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.08, 0),
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

  Future<void> _login(AuthViewModel auth, BuildContext context) async {
    setState(() {
      emailServerError = null;
      passwordServerError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!success) {
      setState(() {
        final message = auth.error ?? "Login failed";

        if (message == "Invalid email address") {
          emailServerError = AppText.get(context, 'invalidEmailAddress');
        } else if (message == "No account found with this email") {
          emailServerError = AppText.get(context, 'noAccountFound');
        } else if (message == "Invalid email or password") {
          emailServerError = AppText.get(context, 'invalidEmailOrPassword');
        } else {
          passwordServerError = AppText.get(context, 'incorrectPassword');
        }
      });

      _formKey.currentState!.validate();
      return;
    }

    if (!context.mounted) return;

   await context.read<ThemeViewModel>().loadThemeForCurrentUser();
await context.read<LanguageViewModel>().loadLanguageForCurrentUser();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      _homeRoute(),
    );
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
              right: -70,
              child: _blurCircle(
                color: theme.colorScheme.primary.withOpacity(0.30),
                size: 210,
              ),
            ),
            Positioned(
              top: 190,
              left: -80,
              child: _blurCircle(
                color: Colors.purple.withOpacity(isDark ? 0.22 : 0.18),
                size: 200,
              ),
            ),
            Positioned(
              bottom: -90,
              right: 30,
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
                                color: theme.colorScheme.primary.withOpacity(
                                  0.36,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.18,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: theme.colorScheme.primary,
                              size: 44,
                            ),
                          ).animate().fadeIn(duration: 500.ms).scale(
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: 22),

                          Text(
                            "BiteWise AI",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideY(begin: .2),

                          const SizedBox(height: 8),

                          Text(
                            AppText.get(context, 'loginSubtitle'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.62,
                              ),
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
                            onChanged: (_) {
                              if (emailServerError != null) {
                                setState(() {
                                  emailServerError = null;
                                });
                              }
                            },
                          ).animate(delay: 260.ms).fadeIn().slideX(begin: -.15),

                          const SizedBox(height: 16),

                          _input(
                            context,
                            passwordController,
                            AppText.get(context, 'password'),
                            Icons.lock_rounded,
                            isPassword: true,
                            validator: validatePassword,
                            onChanged: (_) {
                              if (passwordServerError != null) {
                                setState(() {
                                  passwordServerError = null;
                                });
                              }
                            },
                          ).animate(delay: 340.ms).fadeIn().slideX(begin: .15),

                          const SizedBox(height: 8),

                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () => showResetDialog(context),
                              child: Text(
                                AppText.get(context, 'forgotPassword'),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ).animate(delay: 420.ms).fadeIn(),

                          const SizedBox(height: 16),

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
                                : _primaryGlassButton(
                                    key: const ValueKey("button"),
                                    context: context,
                                    text: AppText.get(context, 'login'),
                                    icon: Icons.login_rounded,
                                    onTap: () {
                                      _login(auth, context);
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
                                  AppText.get(context, 'newHere'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.62),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    _registerRoute(),
                                  );
                                },
                                child: Text(
                                  AppText.get(context, 'createAccount'),
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
    void Function(String)? onChanged,
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
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget _primaryGlassButton({
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
            height: 56,
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
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryGlassButton({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: _glassBox(
        context: context,
        height: 52,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallIconBox(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.34),
        ),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 23,
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