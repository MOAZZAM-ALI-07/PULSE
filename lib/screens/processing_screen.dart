import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analysis_provider.dart';
import 'results_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final List<String> steps = [
    'Reading',
    'Analyzing',
    'Assessing',
    'Planning',
    'Executing'
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);

    // Auto-navigate when done
    if (state.step == 6 && !state.isProcessing && state.runId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen(runId: state.runId!)),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Pipeline Active', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Agentic analysis in progress...', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
              const SizedBox(height: 60),
              
              Expanded(
                child: ListView.builder(
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    int stepNumber = index + 1;
                    bool isCompleted = state.step > stepNumber;
                    bool isActive = state.step == stepNumber;
                    bool isPending = state.step < stepNumber;
                    
                    String stepName = steps[index];
                    String? logText = state.logs[stepName];

                    return _buildNode(
                      stepName: stepName,
                      isCompleted: isCompleted,
                      isActive: isActive,
                      isPending: isPending,
                      isLast: index == steps.length - 1,
                      logText: logText,
                    );
                  },
                ),
              ),
              
              if (state.logs.containsKey('Error'))
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Error: ${state.logs['Error']}', style: const TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
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
  }) {
    Color nodeColor = isCompleted ? Theme.of(context).primaryColor : (isActive ? Theme.of(context).colorScheme.secondary : Colors.grey.withOpacity(0.3));

    Widget node = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? nodeColor.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: nodeColor, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, size: 16, color: nodeColor)
                    : (isActive ? Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: nodeColor)) : const SizedBox()),
              ),
            )
            .animate(target: isActive ? 1 : 0)
            .shimmer(duration: 1.seconds, color: nodeColor.withOpacity(0.5))
            .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 500.ms, curve: Curves.easeInOutSine)
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeInOutSine),
            
            if (!isLast)
              Container(
                width: 2,
                height: logText != null ? 60 : 40,
                color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
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
                  color: isPending ? Colors.grey : (isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              if (logText != null) ...[
                const SizedBox(height: 8),
                Text(
                  logText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'monospace',
                  ),
                ).animate().fade().slideX(begin: 0.1, end: 0),
              ]
            ],
          ),
        ),
      ],
    );

    return node;
  }
}
