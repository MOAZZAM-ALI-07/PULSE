import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';
import 'results_screen.dart';

class ProcessingScreen extends ConsumerWidget {
  const ProcessingScreen({super.key});

  // Aligned with Agentic Workflow steps in state notifier
  static const List<String> _stepNames = [
    'Ingesting Data Streams',
    'Extracting Entities & Relations',
    'Assessing Impact',
    'Generating Actions',
    'Simulating Outcomes',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);

    // FIX: Navigate only when step == 7 (truly done) and no error
    if (!state.isProcessing && state.errorMessage == null && state.step >= 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ResultsScreen(runId: state.runId ?? '')),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, 
                      height: 8, 
                      decoration: BoxDecoration(
                        color: state.errorMessage != null 
                            ? const Color(0xFFE57373)
                            : const Color(0xFF00E676), 
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.errorMessage != null ? 'PIPELINE HALTED' : 'PIPELINE ACTIVE', 
                      style: TextStyle(
                        color: state.errorMessage != null 
                            ? const Color(0xFFE57373) 
                            : const Color(0xFF00E676), 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage != null 
                      ? 'Analysis\nInterrupted' 
                      : 'Agentic Analysis\nIn Progress', 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Pipeline Steps - Show all steps with proper status
                ...List.generate(_stepNames.length, (index) {
                  final stepNumber = index + 1;
                  final isCompleted = state.step > stepNumber;
                  final isActive = state.step == stepNumber && state.isProcessing;
                  final isFailed = state.step == stepNumber && state.errorMessage != null;
                  final isPending = state.step < stepNumber;
                  final isLast = index == _stepNames.length - 1;

                  return _buildStepNode(
                    stepName: _stepNames[index],
                    isCompleted: isCompleted,
                    isActive: isActive,
                    isFailed: isFailed,
                    isPending: isPending,
                    isLast: isLast,
                  );
                }),

                // SERVER ERROR SECTION
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1115),
                      border: Border.all(color: const Color(0xFFE57373), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline, color: Color(0xFFE57373)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Pipeline Processing Halt', style: TextStyle(color: Color(0xFFE57373), fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        // RETRY BUTTON — re-runs the pipeline with same data
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                            label: const Text('RETRY ANALYSIS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                            onPressed: () {
                              final text = state.text;
                              final domain = state.domain;
                              if (text != null && domain != null) {
                                ref.read(analysisProvider.notifier).runFullPipeline(text, domain);
                              } else {
                                // Fallback: go back to input screen
                                ref.read(analysisProvider.notifier).reset();
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        // GO BACK button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              ref.read(analysisProvider.notifier).reset();
                              Navigator.pop(context);
                            },
                            child: const Text('GO BACK', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepNode({
    required String stepName,
    required bool isCompleted,
    required bool isActive,
    required bool isFailed,
    required bool isPending,
    required bool isLast,
  }) {
    final Color nodeColor = isFailed
        ? const Color(0xFFE57373)
        : isCompleted
            ? const Color(0xFF00E676)
            : isActive
                ? const Color(0xFF00E676)
                : Colors.white24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Node circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive 
                    ? const Color(0xFF00E676).withOpacity(0.2) 
                    : isFailed
                        ? const Color(0xFFE57373).withOpacity(0.2)
                        : Colors.transparent,
                border: Border.all(color: nodeColor, width: isActive || isFailed ? 2.5 : 2),
                boxShadow: isActive 
                    ? [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 12)] 
                    : isFailed
                        ? [BoxShadow(color: const Color(0xFFE57373).withOpacity(0.4), blurRadius: 12)]
                        : [],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Color(0xFF00E676))
                    : isFailed
                        ? const Icon(Icons.close, size: 16, color: Color(0xFFE57373))
                        : isActive
                            ? Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E676)))
                            : const SizedBox(),
              ),
            ),
            // Connector line
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? const Color(0xFF00E676).withOpacity(0.5) : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            isActive ? '$stepName...' : isFailed ? '$stepName ✕' : stepName,
            style: TextStyle(
              color: isFailed 
                  ? const Color(0xFFE57373) 
                  : isPending 
                      ? Colors.white30 
                      : Colors.white,
              fontSize: 16,
              fontWeight: isActive || isFailed ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}