import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analyses Trends', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 14, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 15, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 13, color: Theme.of(context).primaryColor)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 10, color: Theme.of(context).primaryColor)]),
                  ],
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Domain Distribution', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 40, color: AppColors.getSeverityColor('Low', isDark), title: 'Business'),
                    PieChartSectionData(value: 30, color: AppColors.getSeverityColor('Medium', isDark), title: 'Finance'),
                    PieChartSectionData(value: 15, color: AppColors.getSeverityColor('High', isDark), title: 'Supply'),
                    PieChartSectionData(value: 15, color: AppColors.getSeverityColor('Critical', isDark), title: 'Other'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
