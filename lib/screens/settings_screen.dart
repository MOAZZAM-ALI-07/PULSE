import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../core/colors.dart';
import '../main.dart';
import '../providers/analysis_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedDomain = 'Business';
  bool _alertsEnabled = true;
  bool _criticalPush = true;

  void _showSnackbar(String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? Colors.white24 : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSelectionDialog(String title, List<String> options, String currentValue, Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => RadioListTile(
            title: Text(opt),
            value: opt,
            groupValue: currentValue,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) {
              if (val != null) onSelect(val);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkPurple.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkAccent.withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildGlassCard(
                  isDark,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                        secondary: Icon(Icons.dark_mode_rounded, color: isDark ? Colors.white : Colors.black87),
                        activeColor: Theme.of(context).primaryColor,
                        value: themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.language_rounded, color: isDark ? Colors.white : Colors.black87),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedLanguage, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () => _showSelectionDialog('Select Language', ['English', 'Urdu', 'Spanish', 'French', 'German'], _selectedLanguage, (val) {
                          setState(() => _selectedLanguage = val);
                          _showSnackbar('Language updated to $val.', isDark);
                        }),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Default Domain', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.domain_rounded, color: isDark ? Colors.white : Colors.black87),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedDomain, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () => _showSelectionDialog('Select Default Domain', ['Business', 'Health', 'Finance', 'Tech'], _selectedDomain, (val) {
                          setState(() => _selectedDomain = val);
                          _showSnackbar('Default domain set to $val.', isDark);
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildGlassCard(
                  isDark,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Analysis Complete Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                        secondary: Icon(Icons.notifications_active_rounded, color: isDark ? Colors.white : Colors.black87),
                        activeColor: Theme.of(context).primaryColor,
                        value: _alertsEnabled,
                        onChanged: (val) {
                          setState(() => _alertsEnabled = val);
                          _showSnackbar(val ? 'Alerts enabled.' : 'Alerts disabled.', isDark);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Critical Severity Push', style: TextStyle(fontWeight: FontWeight.bold)),
                        secondary: Icon(Icons.warning_amber_rounded, color: isDark ? Colors.white : Colors.black87),
                        activeColor: Theme.of(context).primaryColor,
                        value: _criticalPush,
                        onChanged: (val) {
                          setState(() => _criticalPush = val);
                          _showSnackbar(val ? 'Critical push enabled.' : 'Critical push disabled.', isDark);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildGlassCard(
                  isDark,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Export All Data', style: TextStyle(fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.download_rounded, color: isDark ? Colors.white : Colors.black87),
                        onTap: () {
                          _showSnackbar('Exporting data to TXT... Please wait.', isDark);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) _showSnackbar('Data exported successfully!', isDark);
                          });
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text('Clear History', style: TextStyle(color: isDark ? AppColors.darkRed : AppColors.lightRed, fontWeight: FontWeight.bold)),
                        leading: Icon(Icons.delete_forever_rounded, color: isDark ? AppColors.darkRed : AppColors.lightRed),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                              title: const Text('Clear History'),
                              content: const Text('Are you sure you want to permanently delete all analysis history?'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    ref.read(historyProvider.notifier).clearAll();
                                    Navigator.pop(context);
                                    _showSnackbar('History cleared.', isDark);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'PULSE ENGINE v1.0.0\nSecure Intelligence Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
