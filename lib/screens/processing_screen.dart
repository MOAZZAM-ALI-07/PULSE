import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../core/colors.dart';
import '../providers/analysis_provider.dart';
import 'results_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final List<String> steps = [
    'Ingesting Data Streams',
    'Extracting Entities & Relations',
    'Simulating Outcomes',
    'Generating Actions',
    'Finalizing Intelligence'
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.step == 6 && !state.isProcessing && state.runId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => ResultsScreen(runId: state.runId!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ).animate(onPlay: (c) => c.repeat()).moveY(begin: 0, end: 40, duration: 2.seconds).fadeIn(duration: 1.seconds),
            ),
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkAccent.withOpacity(0.2)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.5,1.5), duration: 3.seconds),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.darkAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.darkAccent, blurRadius: 10)],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 800.ms),
                      const SizedBox(width: 16),
                      Text('PIPELINE ACTIVE', style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Agentic Analysis\nIn Progress', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 60),
                  
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      itemBuilder: (context, index) {
                        int stepNumber = index + 1;
                        bool isCompleted = state.step > stepNumber;
                        bool isActive = state.step == stepNumber;
                        bool isPending = state.step < stepNumber;
                        
                        String stepName = steps[index];
                        String logKey = ['Reading', 'Analyzing', 'Assessing', 'Planning', 'Executing'][index];
                        String? logText = state.logs[logKey];

                        return _buildNode(
                          stepName: stepName,
                          isCompleted: isCompleted,
                          isActive: isActive,
                          isPending: isPending,
                          isLast: index == steps.length - 1,
                          logText: logText,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                  
                  if (state.logs.containsKey('Error'))
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkRed.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkRed.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.darkRed),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Error: ${state.logs['Error']}', style: const TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ).animate().shake()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required String stepName,
    required bool isCompleted,
    required bool isActive,
    required bool isPending,
    required bool isLast,
    String? logText,
    required bool isDark,
  }) {
    Color activeColor = AppColors.darkAccent;
    Color completeColor = Theme.of(context).primaryColor;
    Color pendingColor = isDark ? Colors.white12 : Colors.black12;

    Color nodeColor = isCompleted ? completeColor : (isActive ? activeColor : pendingColor);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? nodeColor.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: nodeColor, width: isActive ? 3 : 2),
                boxShadow: isActive ? [BoxShadow(color: nodeColor.withOpacity(0.5), blurRadius: 15)] : [],
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded, size: 20, color: nodeColor)
                    : (isActive ? Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: nodeColor)) : const SizedBox()),
              ),
            )
            .animate(target: isActive ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms, curve: Curves.easeInOutSine)
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeInOutSine),
            
            if (!isLast)
              Container(
                width: 2,
                height: logText != null ? 80 : 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      nodeColor,
                      isCompleted ? completeColor : pendingColor,
                    ]
                  )
                ),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isPending ? (isDark ? Colors.white38 : Colors.black38) : (isActive ? activeColor : (isDark ? Colors.white : Colors.black)),
                ),
              ).animate(target: isActive ? 1 : 0).shimmer(color: activeColor.withOpacity(0.3), duration: 2.seconds),
              if (logText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Text(
                    logText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontFamily: 'monospace',
                    ),
                  ),
                ).animate().fade().slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const double spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
