
import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -90,
            child: _BlurCircle(size: 260),
          ),
          const Positioned(
            bottom: -140,
            right: -120,
            child: _BlurCircle(size: 320),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.055),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 35,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FBF8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.16),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.black,
                                size: 42,
                              ),
                            ).animate().fadeIn(duration: 500.ms).scale(
                                  curve: Curves.easeOutBack,
                                ),

                            const SizedBox(height: 22),

                            Text(
                              AppText.get(context, 'createAccount'),
                              style: const TextStyle(
                                color: Color(0xFFF8FBF8),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ).animate(delay: 100.ms).fadeIn().slideY(begin: .2),

                            const SizedBox(height: 8),

                            Text(
                              AppText.get(context, 'registerSubtitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ).animate(delay: 180.ms).fadeIn().slideY(begin: .2),

                            const SizedBox(height: 34),

                            _input(
                              emailController,
                              AppText.get(context, 'emailAddress'),
                              Icons.email_rounded,
                              validator: validateEmail,
                            ).animate(delay: 260.ms).fadeIn().slideX(begin: -.15),

                            const SizedBox(height: 16),

                            _input(
                              passwordController,
                              AppText.get(context, 'password'),
                              Icons.lock_rounded,
                              isPassword: true,
                              validator: validatePassword,
                            ).animate(delay: 340.ms).fadeIn().slideX(begin: .15),

                            const SizedBox(height: 16),

                            _input(
                              confirmPasswordController,
                              AppText.get(context, 'confirmPassword'),
                              Icons.lock_outline,
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
                                  ? const CircularProgressIndicator(
                                      key: ValueKey("loading"),
                                      color: Color(0xFFF8FBF8),
                                    )
                                  : SizedBox(
                                      key: const ValueKey("button"),
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF8FBF8),
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          final email =
                                              emailController.text.trim();
                                          final password =
                                              passwordController.text.trim();

                                          final success = await auth.register(
                                            email,
                                            password,
                                          );

                                          if (success) {
                                            if (!context.mounted) return;

                                            await context
                                                .read<ThemeViewModel>()
                                                .setTheme(true);

                                            if (!context.mounted) return;

                                            Navigator.pushReplacement(
                                              context,
                                              _fadeSlideRoute(
                                                const ProfileSetupScreen(),
                                              ),
                                            );
                                          } else {
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  auth.error ??
                                                      AppText.get(
                                                        context,
                                                        'registerFailed',
                                                      ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          AppText.get(context, 'createAccount'),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                            ).animate(delay: 500.ms).fadeIn().scale(
                                  begin: const Offset(.96, .96),
                                ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppText.get(context, 'alreadyHaveAccount'),
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontWeight: FontWeight.w500,
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
                                    style: const TextStyle(
                                      color: Color(0xFFF8FBF8),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate(delay: 580.ms).fadeIn().slideY(begin: .2),
                          ],
                        ),
                      ),
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
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        color: Color(0xFFF8FBF8),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFF111111),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFF8FBF8).withOpacity(0.85),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: Color(0xFFF8FBF8),
            width: 1.3,
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
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;

  const _BlurCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.055),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 90,
            spreadRadius: 30,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 2500.ms,
          curve: Curves.easeInOut,
        );
  }
}