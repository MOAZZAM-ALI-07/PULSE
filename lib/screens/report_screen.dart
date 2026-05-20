import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/analysis_model.dart';
import '../core/colors.dart';

class ReportScreen extends StatelessWidget {
  final AnalysisModel analysis;

  const ReportScreen({super.key, required this.analysis});

  void _showActionSnackbar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? Colors.white24 : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showShareMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Share Intelligence', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(context, Icons.link_rounded, 'Copy Link', isDark, () {
                    Navigator.pop(context);
                    _showActionSnackbar(context, 'Secure link copied to clipboard.', isDark);
                  }),
                  _buildShareOption(context, Icons.email_rounded, 'Email', isDark, () {
                    Navigator.pop(context);
                    _showActionSnackbar(context, 'Email draft created.', isDark);
                  }),
                  _buildShareOption(context, Icons.group_add_rounded, 'Team', isDark, () {
                    Navigator.pop(context);
                    _showActionSnackbar(context, 'Shared with Alpha Team.', isDark);
                  }),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _buildShareOption(BuildContext context, IconData icon, String label, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isDark ? Colors.white : Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final severityColor = AppColors.getSeverityColor(analysis.severity, isDark);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Executive Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded), 
            onPressed: () => _showShareMenu(context, isDark),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: severityColor.withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? severityColor.withOpacity(0.05) : severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: severityColor.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(color: severityColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.warning_rounded, color: severityColor, size: 32),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('THREAT LEVEL', style: TextStyle(color: severityColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              const SizedBox(height: 4),
                              Text(analysis.severity.toUpperCase(), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: severityColor, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Text('${(analysis.confidenceAvg).toStringAsFixed(1)}% Confidence Index', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  
                  const SizedBox(height: 32),
                  Text('Synthesis', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                    ),
                    child: Text(
                      analysis.impactData?['summary'] ?? 'No summary available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExportButton(context, Icons.picture_as_pdf_rounded, 'Export PDF', isDark, () {
                        _showActionSnackbar(context, 'PDF Export saved to Downloads.', isDark);
                      }),
                      _buildExportButton(context, Icons.text_snippet_rounded, 'Export TXT', isDark, () {
                        _showActionSnackbar(context, 'TXT Export saved to Downloads.', isDark);
                      }),
                    ],
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showActionSnackbar(context, 'Alert Monitor created for similar signals.', isDark);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_alert_rounded, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text('CREATE ALERT MONITOR', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, IconData icon, String label, bool isDark, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
            ]
          ),
          child: IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon, size: 28),
            padding: const EdgeInsets.all(20),
            style: IconButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
