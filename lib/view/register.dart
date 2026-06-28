import 'dart:ui';

import 'package:bitewise/viewmodel/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_view_model.dart';
import 'login.dart';
import 'profilesetup.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
final _formKey = GlobalKey<FormState>();

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Email is required";
  }

  final emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  if (!emailRegex.hasMatch(value.trim())) {
    return "Enter a valid email address";
  }

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Password is required";
  }

  if (value.length < 8) {
    return "Password must be at least 8 characters";
  }

  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return "Must contain an uppercase letter";
  }

  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return "Must contain a lowercase letter";
  }

  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return "Must contain a number";
  }

  return null;
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
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Color(0xFFF8FBF8),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Start your smart nutrition journey",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 34),

                          _input(
                            emailController,
                            "Email address",
                            Icons.email_rounded,
                             validator: validateEmail,
                          ),

                          const SizedBox(height: 16),

                          _input(
                            passwordController,
                            "Password",
                            Icons.lock_rounded,
                            isPassword: true,
                              validator: validatePassword,
                          ),

                           const SizedBox(height: 16),

                          _input(
                            confirmPasswordController,
                            "Confirm Password",
                            Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                            if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                            }

                           if (value != passwordController.text) {
                            return "Passwords do not match";
                           }
                           return null;
                           },
                           ),

                          const SizedBox(height: 24),

                          auth.isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFFF8FBF8),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF8FBF8),
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final email =
                                          emailController.text.trim();
                                      final password =
                                          passwordController.text.trim();

                              

                                        if (!_formKey.currentState!.validate()) {
                                           return;
                                        }

                                      final success = await auth.register(
                                        email,
                                        password,
                                      );

                                      if (success) {
                                        if (!context.mounted) return;
                                          await context.read<ThemeViewModel>().setTheme(true);

                                        if (!context.mounted) return;

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ProfileSetupScreen(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              auth.error ?? "Register failed",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color(0xFFF8FBF8),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

errorBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(22),
  borderSide: const BorderSide(
    color: Colors.redAccent,
  ),
),

focusedErrorBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(22),
  borderSide: const BorderSide(
    color: Colors.redAccent,
    width: 1.3,
  ),
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
    );
  }
}