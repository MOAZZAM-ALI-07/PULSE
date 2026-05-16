import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Analyses')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Select two analyses to compare side-by-side.'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Select Analyses')),
          ],
        ),
      ),
    );
  }
}
