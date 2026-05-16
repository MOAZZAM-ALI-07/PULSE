import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            trailing: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Default Domain'),
            trailing: const Text('Business'),
            onTap: () {},
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Analysis Complete Notifications'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Critical Severity Alerts'),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Export All Data'),
            leading: const Icon(Icons.download),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Clear History', style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          const Center(child: Text('Pulse v1.0.0', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
