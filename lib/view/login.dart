

import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/view/home.dart';
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
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        title: Text(
          AppText.get(context, 'resetPassword'),
          style: const TextStyle(
            color: Color(0xFFF8FBF8),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: resetEmail,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: Color(0xFFF8FBF8)),
            validator: validateResetEmail,
            decoration: InputDecoration(
              hintText: AppText.get(context, 'enterYourEmail'),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFFF8FBF8),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              errorStyle: const TextStyle(color: Colors.redAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppText.get(context, 'cancel'),
              style: const TextStyle(color: Color(0xFFF8FBF8)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                await auth.forgotPassword(resetEmail.text.trim());

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.get(context, 'passwordResetSent')),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.get(context, 'somethingWentWrong')),
                  ),
                );
              }
            },
            child: Text(AppText.get(context, 'send')),
          ),
        ],
      ).animate().fadeIn(duration: 250.ms).scale(
            begin: const Offset(0.92, 0.92),
            curve: Curves.easeOutBack,
          ),
    );
  }

  Route _homeRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) => const HomeScreen(),
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
      pageBuilder: (_, animation, secondaryAnimation) => const RegisterScreen(),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -90,
            child: _BlurCircle(size: 260),
          ),
          const Positioned(
            bottom: -140,
            left: -120,
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
                                Icons.restaurant_rounded,
                                color: Colors.black,
                                size: 44,
                              ),
                            ).animate().fadeIn(duration: 500.ms).scale(
                                  curve: Curves.easeOutBack,
                                ),

                            const SizedBox(height: 22),

                            const Text(
                              "BiteWise AI",
                              style: TextStyle(
                                color: Color(0xFFF8FBF8),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ).animate(delay: 100.ms).fadeIn().slideY(begin: .2),

                            const SizedBox(height: 8),

                            Text(
                              AppText.get(context, 'loginSubtitle'),
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
                                  style: const TextStyle(
                                    color: Color(0xFFF8FBF8),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ).animate(delay: 420.ms).fadeIn(),

                            const SizedBox(height: 16),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
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
                                        onPressed: () => _login(auth, context),
                                        child: Text(
                                          AppText.get(context, 'login'),
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
                                  AppText.get(context, 'newHere'),
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontWeight: FontWeight.w500,
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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