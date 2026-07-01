
import 'package:bitewise/view/plan.dart';
import 'package:bitewise/view/settings.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:bitewise/widget/dashboard_section.dart';
import 'package:bitewise/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'camera.dart';
import 'chat.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _navScale = 1.0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
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
          ).chain(CurveTween(curve: Curves.easeOutCubic));

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
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

          Positioned(
            left: 24,
            right: 24,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: _homeNavBar(context)
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 450.ms)
                  .slideY(
                    begin: 1,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, DashboardViewModel vm) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BiteWise AI",
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 6),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${AppText.get(context, 'welcome')} ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: vm.userName.isEmpty
                          ? AppText.get(context, 'user')
                          : vm.userName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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

        GestureDetector(
          onTap: () {
            _openPage(const SettingsScreen());
          },
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: theme.colorScheme.onSurface,
              size: 30,
            ),
          )
              .animate()
              .scale(
                duration: 450.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 350.ms),
        ),
      ],
    );
  }

  Widget _homeNavBar(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: _navScale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context: context,
              icon: Icons.camera_alt_outlined,
              onTap: () {
                _openPage(const CameraScreen());
              },
            ),
            _navItem(
              context: context,
              icon: Icons.chat_bubble_outline,
              onTap: () {
                _openPage(const ChatScreen());
              },
            ),
            _navItem(
              context: context,
              icon: Icons.home_rounded,
              isSelected: true,
              isCenter: true,
              onTap: () {},
            ),
            _navItem(
              context: context,
              icon: Icons.history_outlined,
              onTap: () {
                _openPage(const HistoryScreen());
              },
            ),
            _navItem(
              context: context,
              icon: Icons.calendar_month_outlined,
              onTap: () {
                _openPage(const PlanScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isCenter = false,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _navScale = 0.97;
        });
      },
      onTapCancel: () {
        setState(() {
          _navScale = 1.0;
        });
      },
      onTapUp: (_) {
        setState(() {
          _navScale = 1.0;
        });
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isCenter ? 48 : 42,
        height: isCenter ? 48 : 42,
        decoration: BoxDecoration(
          color: isSelected ? theme.scaffoldBackgroundColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.onSurface
              : theme.scaffoldBackgroundColor,
          size: isCenter ? 27 : 24,
        ),
      )
          .animate()
          .fadeIn(duration: 350.ms)
          .scale(
            begin: const Offset(0.85, 0.85),
            duration: 350.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}