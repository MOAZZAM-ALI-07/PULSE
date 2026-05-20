import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';
import '../core/colors.dart';
import '../providers/analysis_provider.dart';
import 'processing_screen.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedDomain = 'Business';
  final List<String> _domains = ['Business', 'Finance', 'Supply Chain', 'Policy', 'Healthcare'];
  String? _fileName;
  bool _isFocused = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _runAnalysis() {
    if (_textController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient data. Provide at least 10 characters.'),
          backgroundColor: AppColors.darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    ref.read(analysisProvider.notifier).runFullPipeline(_textController.text, _selectedDomain);
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const ProcessingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'csv'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _textController.text = "[DATA EXTRACTED FROM: $_fileName]\n\nProcessing intelligence vectors...";
      });
    }
  }

  void _showVoiceInputDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Listening...', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic_rounded, size: 64, color: Theme.of(context).primaryColor),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.3, duration: 800.ms),
              const SizedBox(height: 40),
              Text('Speak your intelligence report.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _textController.text = "Competitor launching a new product next quarter. Market impact estimated at 15% revenue drop.";
                  });
                },
                child: const Text('Stop Recording', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        title: Text('New Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: 50,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkAccent.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkBlue.withOpacity(0.1)),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Input Signal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Text Area
                  FocusScope(
                    child: Focus(
                      onFocusChange: (focus) => setState(() => _isFocused = focus),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isFocused 
                              ? Theme.of(context).primaryColor 
                              : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                            width: _isFocused ? 2 : 1,
                          ),
                          boxShadow: [
                            if (_isFocused)
                              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 20)
                            else if (!isDark)
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: TextField(
                              controller: _textController,
                              maxLines: 8,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                              decoration: InputDecoration(
                                hintText: 'Paste report, article, or raw data here...',
                                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                      ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_textController.text.length} bytes', 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickFile,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_rounded, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _fileName != null ? _fileName! : 'Upload Document',
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _showVoiceInputDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.2)),
                          ),
                          child: Icon(Icons.mic_rounded, color: Theme.of(context).primaryColor),
                        ),
                      )
                    ],
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 32),
                  Text('Domain Routing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Domains
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _domains.map((domain) {
                      final isSelected = _selectedDomain == domain;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDomain = domain),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor 
                                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                            ),
                            boxShadow: isSelected && !isDark ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Text(
                            domain,
                            style: TextStyle(
                              color: isSelected ? (isDark ? AppColors.darkBg : Colors.white) : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 48),
                  
                  // Submit
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _runAnalysis,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('INITIALIZE ANALYSIS', style: TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          Icon(Icons.rocket_launch_rounded),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
