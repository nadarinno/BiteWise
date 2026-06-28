import 'package:bitewise/viewmodel/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DashboardCard extends StatefulWidget {
  const DashboardCard({super.key});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  @override
  

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Dashboard",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),

          const SizedBox(height: 15),

          Text(
            "${vm.todayCalories} / ${vm.goalCalories} kcal",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          LinearProgressIndicator(
            value: vm.progress > 1 ? 1 : vm.progress,
            backgroundColor: Colors.white12,
            color: const Color(0xff22C55E),
            minHeight: 10,
          ),

          const SizedBox(height: 8),

          Text(
            "${(vm.progress * 100).toStringAsFixed(0)}% of daily goal",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          if (vm.todayPlan != null)
            Text(
              "Today's Plan: ${vm.todayPlan!.totalCalories} kcal",
              style: const TextStyle(color: Colors.white70),
            )
          else
            const Text(
              "No plan generated yet",
              style: TextStyle(color: Colors.white54),
            ),
        ],
      ),
    );
  }
}