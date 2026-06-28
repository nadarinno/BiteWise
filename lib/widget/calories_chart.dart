
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CaloriesChartModern extends StatelessWidget {
  final List<int> calories;
  final int goal;
  final int todayCalories;
  final int remainingCalories;
  final int takenCalories;

  const CaloriesChartModern({
    super.key,
    required this.calories,
    required this.goal,
    required this.todayCalories,
    required this.remainingCalories,
    required this.takenCalories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeCalories = List<int>.generate(
      7,
      (index) => index < calories.length ? calories[index] : 0,
    );

    final maxCalories = [
      ...safeCalories,
      goal,
      todayCalories,
    ].reduce((a, b) => a > b ? a : b);

    final maxY = maxCalories + 500.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Calories",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 26,
                height: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Goal ($goal kcal)",
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 280,
            child: BarChart(
              key: ValueKey(safeCalories.join("-")),
              BarChartData(
                minY: 0,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor.withOpacity(0.7),
                      strokeWidth: 1,
                    );
                  },
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal.toDouble(),
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      strokeWidth: 1.5,
                      dashArray: [8, 6],
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return _axisText(context, "0");
                        if (value == 500) return _axisText(context, "500");
                        if (value == 1000) return _axisText(context, "1K");
                        if (value == 1500) return _axisText(context, "1.5K");
                        if (value == 2000) return _axisText(context, "2K");
                        if (value == 2500) return _axisText(context, "2.5K");
                        if (value == 3000) return _axisText(context, "3K");
                        if (value == 3500) return _axisText(context, "3.5K");
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const days = ["M", "T", "W", "T", "F", "S", "S"];
                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${rod.toY.toInt()} kcal",
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final value = safeCalories[i];
                  final todayIndex = DateTime.now().weekday - 1;
                  final isToday = i == todayIndex;

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: value.toDouble(),
                        width: 20,
                        borderRadius: BorderRadius.circular(14),
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: goal.toDouble(),
                          color: theme.dividerColor.withOpacity(0.35),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 700),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _axisText(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}