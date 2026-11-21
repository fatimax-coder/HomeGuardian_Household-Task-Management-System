import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../controllers/task_controller.dart';
import '../app_illustration.dart';

/// Task Completion Donut Chart using fl_chart
/// Visualizes completed, in-progress, and pending chores from real task records
class TaskCompletionChart extends StatelessWidget {
  final TaskController taskController;

  const TaskCompletionChart({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    final total = taskController.totalTasksCount;
    final completed = taskController.completedTasksCount;
    final inProgress = taskController.inProgressTasksCount;
    final pending = taskController.pendingTasksCount;

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
                  'Task Completion',
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
                    '$total Tasks',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      AppIllustration.emptyTasks(size: 72),
                      const SizedBox(height: 10),
                      const Text(
                        'No tasks created yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add household chores to view completion progress.',
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
              Row(
                children: [
                  // Donut PieChart
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: [
                              if (completed > 0)
                                PieChartSectionData(
                                  value: completed.toDouble(),
                                  color: AppColors.success,
                                  title: '',
                                  radius: 20,
                                ),
                              if (inProgress > 0)
                                PieChartSectionData(
                                  value: inProgress.toDouble(),
                                  color: AppColors.sand,
                                  title: '',
                                  radius: 20,
                                ),
                              if (pending > 0)
                                PieChartSectionData(
                                  value: pending.toDouble(),
                                  color: AppColors.terracotta,
                                  title: '',
                                  radius: 20,
                                ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${((completed / total) * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Legend Breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendRow(
                          color: AppColors.success,
                          label: 'Completed',
                          count: completed,
                          total: total,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendRow(
                          color: AppColors.sand,
                          label: 'In Progress',
                          count: inProgress,
                          total: total,
                        ),
                        const SizedBox(height: 8),
                        _buildLegendRow(
                          color: AppColors.terracotta,
                          label: 'Pending',
                          count: pending,
                          total: total,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final pct = total > 0 ? ((count / total) * 100).round() : 0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.darkBrown),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
      ],
    );
  }
}

