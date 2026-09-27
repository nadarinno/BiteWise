


import 'dart:ui';

import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/utils/app_theme.dart';
import 'package:bitewise/view/settings.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/widget/dashboard_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
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
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 115),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, vm)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(
                          begin: -0.25,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 28),

                    const DashboardSection()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.18,
                          curve: Curves.easeOutCubic,
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DashboardViewModel vm) {
    final theme = Theme.of(context);

    return _glassBox(
      context: context,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BiteWise AI",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${AppText.get(context, 'welcome')} ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: vm.userName.isEmpty
                            ? AppText.get(context, 'user')
                            : vm.userName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text: " 👋",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          GestureDetector(
            onTap: () {
              _openPage(const SettingsScreen());
            },
            child: _settingsGlassButton(context)
                .animate()
                .scale(
                  duration: 450.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 350.ms),
          ),
        ],
      ),
    );
  }

  Widget _settingsGlassButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.settings_rounded,
            color: theme.colorScheme.primary,
            size: 30,
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
}