import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        // FIX: Is SingleChildScrollView ki wajah se overflow hamesha k liye khatam
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Input Signal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF00E676), width: 2),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _textController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Paste report, article, or raw data here...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                  onChanged: (text) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_textController.text.length} characters',
                  style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.note_add, color: Color(0xFF00E676)),
                      label: const Text('Upload Document', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.mic, color: Color(0xFF00E676)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Domain Routing',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Business', 'Finance', 'Supply Chain', 'Policy', 'Healthcare'].map((domain) {
                  final isSelected = _selectedDomain == domain;
                  return ChoiceChip(
                    label: Text(domain),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF1A1A1A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedDomain = domain;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: _textController.text.trim().isEmpty 
                    ? null 
                    : () {
                        ref.read(analysisProvider.notifier).runFullPipeline(
                          _textController.text.trim(),
                          _selectedDomain,
                        );
                        // Navigate directly to ProcessingScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProcessingScreen()),
                        );
                      },
                  child: const Text(
                    'INITIALIZE ANALYSIS',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}