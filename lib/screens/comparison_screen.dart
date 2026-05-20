import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../core/colors.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  void _showReportSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Reports to Compare', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.description_rounded, color: Theme.of(context).primaryColor),
                title: const Text('Q3 Marketing Strategy'),
                trailing: const Icon(Icons.check_circle_outline_rounded),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Q3 Marketing Strategy selected.'), backgroundColor: isDark ? Colors.white24 : Colors.black87));
                },
              ),
              ListTile(
                leading: Icon(Icons.description_rounded, color: Theme.of(context).primaryColor),
                title: const Text('Competitor Expansion Plan'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Comparison started.'), backgroundColor: isDark ? Colors.white24 : Colors.black87));
                },
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Compare', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: 50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkAmber.withOpacity(0.1)),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.3,1.3), duration: 4.seconds),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (!isDark) BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 20)
                        ]
                      ),
                      child: Icon(Icons.compare_arrows_rounded, size: 80, color: Theme.of(context).primaryColor),
                    ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
                    const SizedBox(height: 32),
                    Text(
                      'Cross-Analysis Engine',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select two intelligence reports to synthesize insights, identify contradictions, and model compounded risks.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDark ? Colors.white54 : Colors.black54, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _showReportSelector,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded),
                          SizedBox(width: 8),
                          Text('Select Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
