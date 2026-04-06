import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_helpers.dart';

class IncomeExpenseBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> monthlyData;

  const IncomeExpenseBarChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = DateHelpers.getLast6Months();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income vs Expenses',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    _Legend(color: AppColors.income, label: 'Income'),
                    const SizedBox(width: 12),
                    _Legend(color: AppColors.expense, label: 'Expenses'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          theme.colorScheme.surface,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= months.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateHelpers.formatMonthYear(months[idx]),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withAlpha(150),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, _) => Text(
                          '\$${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withAlpha(80),
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: List.generate(months.length, (i) {
                    final key = DateHelpers.formatMonthYear(months[i]);
                    final data = monthlyData[key] ?? {};
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data['income'] ?? 0,
                          color: AppColors.income,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: data['expenses'] ?? 0,
                          color: AppColors.expense,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _maxY {
    double max = 0;
    for (final data in monthlyData.values) {
      final income = data['income'] ?? 0;
      final expenses = data['expenses'] ?? 0;
      if (income > max) max = income;
      if (expenses > max) max = expenses;
    }
    return max == 0 ? 1000 : max * 1.2;
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
