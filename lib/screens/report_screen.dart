import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../core/colors.dart';

class ReportScreen extends StatelessWidget {
  final AnalysisModel analysis;

  const ReportScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final severityColor = AppColors.getSeverityColor(analysis.severity, isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Report'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: severityColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: severityColor, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall Severity: ${analysis.severity}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: severityColor)),
                        const SizedBox(height: 4),
                        Text('${(analysis.confidenceAvg).toStringAsFixed(1)}% Average Confidence', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              analysis.impactData?['summary'] ?? 'No summary available.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportButton(context, Icons.picture_as_pdf, 'Export PDF'),
                _buildExportButton(context, Icons.data_object, 'Export JSON'),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_alert),
                label: const Text('Set Alert for similar signals'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: () {},
          icon: Icon(icon, size: 32),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
