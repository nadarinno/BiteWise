

import 'dart:ui';

import 'package:bitewise/services/auth_service.dart';
import 'package:bitewise/utils/app_theme.dart';
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

  Route _loginRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) {
        return const LoginScreen();
      },
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
        _loginRoute(),
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
    final isDark = theme.brightness == Brightness.dark;
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

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
                color: Colors.red.withOpacity(isDark ? 0.22 : 0.16),
                size: 210,
              ),
            ),
            Positioned(
              top: 190,
              right: -70,
              child: _blurCircle(
                color: theme.colorScheme.primary.withOpacity(0.24),
                size: 190,
              ),
            ),
            Positioned(
              bottom: -90,
              left: 30,
              child: _blurCircle(
                color: Colors.purple.withOpacity(isDark ? 0.18 : 0.14),
                size: 190,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: _topBar(context),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                      child: Column(
                        children: [
                          _glassBox(
                            context: context,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 32,
                            ),
                            borderRadius: BorderRadius.circular(34),
                            child: Column(
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(
                                      isDark ? 0.18 : 0.11,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.45),
                                      width: 1.3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.16),
                                        blurRadius: 28,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 58,
                                  ),
                                ).animate().fadeIn(duration: 400.ms).scale(
                                      curve: Curves.easeOutBack,
                                    ),

                                const SizedBox(height: 22),

                                Text(
                                  AppText.get(
                                    context,
                                    'deleteAccountWarning',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.45,
                                  ),
                                )
                                    .animate(delay: 100.ms)
                                    .fadeIn()
                                    .slideY(begin: .15),

                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                        isDark ? 0.06 : 0.30,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(
                                          isDark ? 0.12 : 0.42,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      email,
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.72),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                      .animate(delay: 180.ms)
                                      .fadeIn()
                                      .slideY(begin: .15),
                                ],

                                const SizedBox(height: 28),

                                _passwordInput(context)
                                    .animate(delay: 260.ms)
                                    .fadeIn()
                                    .slideX(begin: -.12),

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
                                      ? _glassBox(
                                          key: const ValueKey("loading"),
                                          context: context,
                                          padding: const EdgeInsets.all(20),
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          child: const SizedBox(
                                            width: 26,
                                            height: 26,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.6,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      : _deleteButton(
                                          key: const ValueKey("delete"),
                                          context: context,
                                          onTap: _deleteAccount,
                                        ),
                                ).animate(delay: 340.ms).fadeIn().scale(
                                      begin: const Offset(.96, .96),
                                    ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 450.ms).slideY(
                                begin: .12,
                                curve: Curves.easeOutCubic,
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _glassIconButton(
          context: context,
          icon: Icons.arrow_back_rounded,
          color: theme.colorScheme.primary,
          onTap: () {
            Navigator.pop(context);
          },
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _glassBox(
            context: context,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  AppText.get(context, 'deleteAccount'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordInput(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: TextField(
          controller: passwordController,
          obscureText: true,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          cursorColor: Colors.red,
          decoration: InputDecoration(
            hintText: AppText.get(context, 'enterPassword'),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.48),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.red,
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
                color: Colors.red.withOpacity(0.75),
                width: 1.7,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteButton({
    Key? key,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: Colors.red.withOpacity(isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.red.withOpacity(0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  AppText.get(context, 'deleteAccountPermanently'),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16,
            sigmaY: 16,
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.42),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
                width: 1.1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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