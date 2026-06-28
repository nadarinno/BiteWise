
import 'package:bitewise/view/plan.dart';
import 'package:bitewise/view/settings.dart';
import 'package:bitewise/viewmodel/dashboard_view_model.dart';

import 'package:bitewise/widget/dashboard_section.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DashboardViewModel>().loadDashboard();
    });
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
                  _header(context, vm),
                  const SizedBox(height: 28),
                  const DashboardSection(),
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
              child: _homeNavBar(context),
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
              Text("BiteWise AI", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome back, ",
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                    ),
                    TextSpan(
                      text: vm.userName.isEmpty ? "User" : vm.userName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: " 👋", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
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
          ),
        ),
      ],
    );
  }

  Widget _homeNavBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
          ),
          _navItem(
            context: context,
            icon: Icons.chat_bubble_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          _navItem(
            context: context,
            icon: Icons.calendar_month_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanScreen()),
              );
            },
          ),
        ],
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
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
      ),
    );
  }
}