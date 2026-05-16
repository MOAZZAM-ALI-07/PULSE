import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/analysis_model.dart';
import '../providers/analysis_provider.dart';
import '../core/colors.dart';
import 'main_layout.dart';
import 'report_screen.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final String runId;
  const ResultsScreen({super.key, required this.runId});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use state.result if available, otherwise fetch from runId (mock for now, assume state.result is there if we just ran it)
    final AnalysisModel? analysis = state.result;

    if (analysis == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(analysisProvider.notifier).reset();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainLayout()),
              (route) => false,
            );
          },
        ),
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen(analysis: analysis)),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Insights'),
            Tab(text: 'Actions'),
            Tab(text: 'Execution'),
            Tab(text: 'Raw Signals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsightsTab(analysis.insightsData?['insights'] ?? [], isDark),
          _buildActionsTab(analysis.actionsData?['actions'] ?? []),
          _buildExecutionTab(analysis.executionData ?? {}),
          _buildRawSignalsTab(analysis.ingestionData?['signals'] ?? []),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List<dynamic> insights, bool isDark) {
    if (insights.isEmpty) return const Center(child: Text('No insights found.'));

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: insights.length,
        itemBuilder: (context, index) {
          final insight = insights[index];
          final confidence = insight['confidence'] ?? 0;
          final severity = insight['severity'] ?? 'Medium';
          final severityColor = AppColors.getSeverityColor(severity, isDark);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: severityColor, width: 4)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: severityColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(severity, style: TextStyle(color: severityColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(insight['tag'] ?? 'Tag', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(insight['text'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(insight['explanation'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Confidence:', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: confidence / 100,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${confidence.toInt()}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.thumb_down_alt_outlined, size: 20),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border, size: 20),
                                onPressed: () {},
                              ),
                            ],
                          )
                        ],
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
  }

  Widget _buildActionsTab(List<dynamic> actions) {
    if (actions.isEmpty) return const Center(child: Text('No actions generated.'));

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          final priority = action['priority'] ?? 'P3';
          
          Color priorityColor = Colors.grey;
          if (priority == 'P1') priorityColor = AppColors.darkRed;
          if (priority == 'P2') priorityColor = AppColors.darkAmber;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              foregroundColor: Theme.of(context).primaryColor,
                              child: Text('${action['rank'] ?? index + 1}'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(action['title'] ?? '', style: Theme.of(context).textTheme.titleLarge)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: priorityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text(priority, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(action['description'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Icon(Icons.track_changes, size: 16, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Expected: ${action['expected_outcome']}', style: Theme.of(context).textTheme.bodySmall)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Mark as Done'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExecutionTab(Map<String, dynamic> execution) {
    if (execution.isEmpty) return const Center(child: Text('No execution data.'));

    final email = execution['email'] ?? {};
    final crm = execution['crm_update'] ?? {};
    final dashboard = execution['dashboard_update'] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Dashboard Simulation
        Text('Dashboard Impact', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(dashboard['metric_name'] ?? 'Metric', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Before', style: Theme.of(context).textTheme.bodySmall),
                        Text(dashboard['before_value'] ?? '-', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                    Column(
                      children: [
                        Text('After', style: Theme.of(context).textTheme.bodySmall),
                        Text(dashboard['after_value'] ?? '-', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${dashboard['direction'] == 'up' ? '▲' : '▼'} ${dashboard['change_percent']}',
                  style: TextStyle(
                    color: dashboard['direction'] == 'up' ? AppColors.darkAccent : AppColors.darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade().slideY(begin: 0.1, end: 0),
        
        const SizedBox(height: 24),
        
        // Email Draft
        Text('Email Draft', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('To: ${email['to']}', style: Theme.of(context).textTheme.bodySmall),
                Text('Subject: ${email['subject']}', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                Text(email['body'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 24),

        // CRM JSON Diff
        Text('CRM Record Update', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${crm['record_type']}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Before:', style: TextStyle(color: Colors.redAccent)),
                          Text(crm['before'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('After:', style: TextStyle(color: Colors.greenAccent)),
                          Text(crm['after'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildRawSignalsTab(List<dynamic> signals) {
    if (signals.isEmpty) return const Center(child: Text('No signals extracted.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: signals.map((signal) {
          final isNumber = signal['signal_type'] == 'number' || signal['signal_type'] == 'percentage';
          return Chip(
            label: Text(signal['text'] ?? ''),
            backgroundColor: isNumber ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).cardColor,
            side: BorderSide(color: isNumber ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
          ).animate().fade().scale();
        }).toList(),
      ),
    );
  }
}
