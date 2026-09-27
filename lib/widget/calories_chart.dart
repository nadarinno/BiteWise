
import 'package:bitewise/utils/app_text.dart';
import 'package:bitewise/widget/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CaloriesChartModern extends StatelessWidget {
  final List<int> calories;
  final int goal;
  final int todayCalories;
  final int remainingCalories;
  final int takenCalories;
  final int highlightedIndex;

  const CaloriesChartModern({
    super.key,
    required this.calories,
    required this.goal,
    required this.todayCalories,
    required this.remainingCalories,
    required this.takenCalories,
    required this.highlightedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCalories = _getMaxCalories();
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      blur: 18,
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.get(context, 'weeklyCalories'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "${AppText.get(context, 'goal')} ($goal ${AppText.get(context, 'kcal')})",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 240,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: BarChart(
                BarChartData(
                  maxY: maxCalories.toDouble(),
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxCalories / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(
                          isDark ? 0.08 : 0.25,
                        ),
                        strokeWidth: 1,
                      );
                    },
                  ),

                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: maxCalories / 4,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              _formatCaloriesAxis(value),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.65),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index > 6) {
                            return const SizedBox.shrink();
                          }

                          final days = [
                            AppText.get(context, 'M'),
                            AppText.get(context, 'T'),
                            AppText.get(context, 'W'),
                            AppText.get(context, 'T'),
                            AppText.get(context, 'F'),
                            AppText.get(context, 'S'),
                            AppText.get(context, 'S'),
                          ];

                          final isHighlighted = index == highlightedIndex;

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Text(
                              days[index],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: isHighlighted
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.75),
                                fontWeight: isHighlighted
                                    ? FontWeight.w900
                                    : FontWeight.w700,
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
                      tooltipRoundedRadius: 14,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${rod.toY.toInt()} ${AppText.get(context, 'kcal')}",
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                  ),

                  barGroups: List.generate(7, (index) {
                    final value = index < calories.length ? calories[index] : 0;
                    final isHighlighted = index == highlightedIndex;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          width: isHighlighted ? 18 : 14,
                          borderRadius: BorderRadius.circular(18),
                          color: isHighlighted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.45),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCalories.toDouble(),
                            color: Colors.white.withOpacity(
                              isDark ? 0.06 : 0.24,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _miniInfo(
                  context: context,
                  title: AppText.get(context, 'today'),
                  value: todayCalories,
                  icon: Icons.local_fire_department_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _miniInfo(
                  context: context,
                  title: AppText.get(context, 'remaining'),
                  value: remainingCalories,
                  icon: Icons.bolt_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).scale(
          begin: const Offset(.97, .97),
          curve: Curves.easeOutCubic,
        );
  }

  int _getMaxCalories() {
    final maxFromList = calories.isEmpty
        ? 0
        : calories.reduce((a, b) => a > b ? a : b);

    final maxValue = [
      maxFromList,
      goal,
      todayCalories,
      takenCalories,
    ].reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return 1000;

    return ((maxValue / 500).ceil() * 500).toInt();
  }

  String _formatCaloriesAxis(double value) {
  final intValue = value.toInt();

  if (intValue == 0) return "";

  if (intValue >= 1000) {
    final kValue = intValue / 1000;

    if (kValue == kValue.roundToDouble()) {
      return "${kValue.toInt()}K";
    }

    return "${kValue.toStringAsFixed(1)}K";
  }

  return intValue.toString();
}

  Widget _miniInfo({
    required BuildContext context,
    required String title,
    required int value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      borderRadius: BorderRadius.circular(18),
      blur: 10,
      opacity: 0.06,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.08 : 0.30),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.12 : 0.45),
                ),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "$value ${AppText.get(context, 'kcal')}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}