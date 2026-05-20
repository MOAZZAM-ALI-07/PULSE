import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../core/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Dynamic Background
          if (isDark) ...[
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkBlue.withOpacity(0.15)),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkRed.withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Intelligence Volume', Icons.show_chart_rounded),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    isDark,
                    child: SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            _buildBarGroup(1, 8, isDark),
                            _buildBarGroup(2, 10, isDark),
                            _buildBarGroup(3, 14, isDark),
                            _buildBarGroup(4, 15, isDark),
                            _buildBarGroup(5, 13, isDark),
                            _buildBarGroup(6, 10, isDark),
                          ],
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true, 
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black12, strokeWidth: 1, dashArray: [5, 5]),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('D${value.toInt()}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                              );
                            })),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Domain Distribution', Icons.pie_chart_outline_rounded),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    isDark,
                    child: SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: [
                            _buildPieSection(40, AppColors.getSeverityColor('Low', isDark), 'Business', isDark),
                            _buildPieSection(30, AppColors.getSeverityColor('Medium', isDark), 'Finance', isDark),
                            _buildPieSection(15, AppColors.getSeverityColor('High', isDark), 'Supply', isDark),
                            _buildPieSection(15, AppColors.getSeverityColor('Critical', isDark), 'Other', isDark),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGlassCard(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isDark) {
    return BarChartGroupData(
      x: x, 
      barRods: [
        BarChartRodData(
          toY: y, 
          color: AppColors.darkAccent,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          )
        )
      ]
    );
  }

  PieChartSectionData _buildPieSection(double value, Color color, String title, bool isDark) {
    return PieChartSectionData(
      value: value, 
      color: color, 
      title: title,
      titleStyle: TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.bold, 
        color: isDark ? Colors.white : Colors.black87,
        shadows: isDark ? [const Shadow(color: Colors.black, blurRadius: 2)] : [],
      ),
      radius: 50,
      badgeWidget: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
        child: Icon(Icons.circle, size: 8, color: color),
      ),
      badgePositionPercentageOffset: 1.2,
    );
  }
}
