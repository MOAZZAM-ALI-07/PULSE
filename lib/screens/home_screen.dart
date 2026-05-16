import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_model.dart';
import '../core/colors.dart';
import 'results_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedDomain = 'Business';
  final List<String> domains = ['Business', 'Finance', 'Supply Chain', 'Policy', 'Healthcare'];

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(getGreeting(), style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(historyProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(historyAsync),
                const SizedBox(height: 24),
                Text('Domain', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildDomainPills(),
                const SizedBox(height: 24),
                Text('Recent Analyses', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildRecentAnalyses(historyAsync, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AsyncValue<List<AnalysisModel>> historyAsync) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: historyAsync.when(
          data: (history) {
            int total = history.length;
            // Simplistic averages
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Analyses', '$total', Icons.analytics),
                _buildSummaryItem('Avg Risk', 'Med', Icons.warning_amber),
                _buildSummaryItem('Top', 'Business', Icons.business),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Failed to load summary'),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDomainPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: domains.map((domain) {
          final isSelected = selectedDomain == domain;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(domain),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => selectedDomain = domain);
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentAnalyses(AsyncValue<List<AnalysisModel>> historyAsync, bool isDark) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No analyses yet. Tap + to start.'),
            ),
          );
        }
        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length > 5 ? 5 : history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          // Navigate to Results
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(runId: item.runId)));
                        },
                        title: Text(item.domain, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.getSeverityColor(item.severity, isDark).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.getSeverityColor(item.severity, isDark)),
                          ),
                          child: Text(
                            item.severity,
                            style: TextStyle(
                              color: AppColors.getSeverityColor(item.severity, isDark),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading history'),
    );
  }
}
