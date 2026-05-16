import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _runAnalysis() {
    if (_textController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 10 characters')),
      );
      return;
    }
    
    // Start pipeline
    ref.read(analysisProvider.notifier).runFullPipeline(_textController.text, _selectedDomain);
    
    // Navigate to processing screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProcessingScreen()),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _textController.text = "Simulated extracted text from $_fileName...";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Input Signal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Paste report, article, or raw data here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ).animate().fade().slideY(begin: 0.1, end: 0),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('${_textController.text.length} characters', style: Theme.of(context).textTheme.bodySmall),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_fileName != null ? 'File: $_fileName' : 'Upload PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () {
                    // Voice input mock
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice input not implemented in demo')));
                  },
                  icon: const Icon(Icons.mic),
                  padding: const EdgeInsets.all(16),
                )
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),
            Text('Domain', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _domains.map((domain) {
                return ChoiceChip(
                  label: Text(domain),
                  selected: _selectedDomain == domain,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDomain = domain);
                  },
                );
              }).toList(),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _runAnalysis,
              child: const Text('Run Analysis'),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
