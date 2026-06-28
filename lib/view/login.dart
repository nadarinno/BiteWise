
import 'dart:ui';
import 'package:bitewise/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_view_model.dart';
import 'register.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});


  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  
  final _formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w\.-]+@gmail\.com$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid Gmail address";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.trim().length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
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
        side: BorderSide(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      title: const Text(
        "Reset Password",
        style: TextStyle(
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Email is required";
            }

            final emailRegex =
                RegExp(r'^[\w\.-]+@gmail\.com$');

            if (!emailRegex.hasMatch(value.trim())) {
              return "Enter a valid Gmail address";
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: "Enter your email",
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFFF8FBF8),
            ),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFF8FBF8),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFFF8FBF8)),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            try {
              await auth.forgotPassword(resetEmail.text.trim());

              if (!context.mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset email sent successfully."),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(auth.error ?? "Something went wrong"),
                ),
              );
            }
          },
          child: const Text("Send"),
        ),
      ],
    ),
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
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Smart nutrition. Clean choices.",
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

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => showResetDialog(context),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFFF8FBF8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

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
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final success = await auth.login(
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (success) {
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error ?? "Login failed"),
      ),
    );
  }
},
                                    child: const Text(
                                      "Login",
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
                                "New here?",
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Create account",
                                  style: TextStyle(
                                    color: Color(0xFFF8FBF8),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          )
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
    controller: controller,
    obscureText: isPassword,
    validator: validator,
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
    );
  }
}