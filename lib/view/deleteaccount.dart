

import 'package:bitewise/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bitewise/view/login.dart';
import 'package:bitewise/utils/app_text.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.get(context, 'passwordRequired')),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService().reauthenticateAndDeleteAccount(password);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, secondaryAnimation) => LoginScreen(),
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
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = AppText.get(context, 'somethingWentWrong');

      if (e.code == "invalid-credential" || e.code == "wrong-password") {
        message = AppText.get(context, 'incorrectPassword');
      } else if (e.code == "requires-recent-login") {
        message = AppText.get(context, 'pleaseTryAgain');
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppText.get(context, 'error')}: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppText.get(context, 'deleteAccount'),
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 70,
            ).animate().fadeIn(duration: 400.ms).scale(
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 20),

            Text(
              AppText.get(context, 'deleteAccountWarning'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ).animate(delay: 100.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 12),

            Text(
              email,
              style: theme.textTheme.bodyMedium,
            ).animate(delay: 180.ms).fadeIn().slideY(begin: .15),

            const SizedBox(height: 30),

            TextField(
              controller: passwordController,
              obscureText: true,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: AppText.get(context, 'enterPassword'),
                prefixIcon: const Icon(Icons.lock),
              ),
            ).animate(delay: 260.ms).fadeIn().slideX(begin: -.12),

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
              child: isLoading
                  ? const CircularProgressIndicator(
                      key: ValueKey("loading"),
                    )
                  : OutlinedButton(
                      key: const ValueKey("delete"),
                      onPressed: _deleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        AppText.get(context, 'deleteAccountPermanently'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ).animate(delay: 340.ms).fadeIn().scale(
                  begin: const Offset(.96, .96),
                ),
          ],
        ),
      ),
    );
  }
}