import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../controllers/appliance_controller.dart';
import '../app_illustration.dart';

/// Monthly Maintenance Expense Chart using fl_chart
/// Visualizes actual maintenance costs based on logged service records.
/// No fabricated data is shown.
class MaintenanceExpenseChart extends StatelessWidget {
  final ApplianceController applianceController;

  const MaintenanceExpenseChart({super.key, required this.applianceController});

  @override
  Widget build(BuildContext context) {
    final expenses = applianceController.monthlyExpenses;
    final totalCost = applianceController.totalMaintenanceCost;
    final hasData = applianceController.hasMaintenanceRecords && totalCost > 0;

    final monthKeys = expenses.keys.toList();
    final expenseValues = expenses.values.toList();
    final maxExpense = expenseValues.fold(0.0, (m, v) => v > m ? v : m);

    return Card(
      color: AppColors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.sand, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maintenance Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sand.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '\$${totalCost.toStringAsFixed(2)} Total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      AppIllustration.maintenance(size: 64),
                      const SizedBox(height: 10),
                      const Text(
                        'No maintenance expenses recorded yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Log appliance repairs and service to track monthly costs.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxExpense == 0 ? 100 : maxExpense * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.darkBrown,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = monthKeys[group.x.toInt()];
                          return BarTooltipItem(
                            '$label\n\$${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx >= 0 && idx < monthKeys.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  monthKeys[idx].split(' ').first,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.sand.withValues(alpha: 0.4),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(monthKeys.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: expenseValues[i],
                            color: expenseValues[i] > 0
                                ? AppColors.terracotta
                                : AppColors.sand.withValues(alpha: 0.4),
                            width: 18,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5)),
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
}
