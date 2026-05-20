import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';
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

  void _showActionSnackbar(String message, bool isDark) {
    // Purane SnackBar ko clear karne ke liye taaki overlapping na ho
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? Colors.white24 : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(analysisProvider);
      if (currentState.result == null || currentState.runId != widget.runId) {
        ref.read(analysisProvider.notifier).loadAnalysis(widget.runId);
      }
    });
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

    final AnalysisModel? analysis = state.result;

    if (analysis == null) {
      return Scaffold(
        body: Center(
          child: state.errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load analysis: ${state.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
                        onPressed: () {
                          ref.read(analysisProvider.notifier).reset();
                          Navigator.pop(context);
                        },
                        child: const Text('GO BACK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(color: Theme.of(context).primaryColor)
                  .animate()
                  .fadeIn(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Glassmorphism ke liye background color transparent aur elevation 0 kiya
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(analysisProvider.notifier).reset();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainLayout()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Analysis Results', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8), // Padding fix ki
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.summarize_rounded, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => ReportScreen(analysis: analysis),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ).animate().fadeIn(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Insights'),
                    Tab(text: 'Actions'),
                    Tab(text: 'Execution'),
                    Tab(text: 'Raw Signals'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkBlue.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: 50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkPurple.withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.transparent),
            ),
          ],
          // SafeArea ko hataya taaki background dynamic blur sahi se dikhe, padding ListView me handle ki hai
          TabBarView(
            controller: _tabController,
            children: [
              _buildInsightsTab(analysis.insightsData?['insights'] ?? [], isDark),
              _buildActionsTab(analysis.actionsData?['actions'] ?? [], isDark),
              _buildExecutionTab(analysis.executionData ?? {}, isDark),
              _buildRawSignalsTab(analysis.ingestionData?['signals'] ?? [], isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, bool isDark, {required Widget child, Border? border}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.6) : Colors.white.withOpacity(0.8), // Light mode me bhi opacity lagayi glass effect ke liye
        borderRadius: BorderRadius.circular(24),
        border: border ?? Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInsightsTab(List<dynamic> insights, bool isDark) {
    if (insights.isEmpty) return _buildEmptyState('No insights found.', Icons.lightbulb_outline_rounded, isDark);

    return AnimationLimiter(
      child: ListView.builder(
        // Top padding badhayi taaki extendBodyBehindAppBar ki wajah se content AppBar ke peeche na chupe
        padding: const EdgeInsets.only(top: kToolbarHeight + 80, left: 20, right: 20, bottom: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: insights.length,
        itemBuilder: (context, index) {
          if (insights[index] is! Map) return const SizedBox.shrink();
          final insight = Map<String, dynamic>.from(insights[index] as Map);
          final rawConf = insight['confidence'];
          final confidence = (rawConf is num) ? rawConf.toDouble() : 0.0;
          final severity = insight['severity']?.toString() ?? 'Medium';
          final severityColor = AppColors.getSeverityColor(severity, isDark);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              curve: Curves.easeOutCubic,
              child: FadeInAnimation(
                child: _buildGlassCard(
                  context,
                  isDark,
                  border: Border.all(color: severityColor.withOpacity(0.3)),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: severityColor, width: 4)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: severityColor.withOpacity(0.5)),
                              ),
                              child: Text(severity.toString().toUpperCase(), style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(insight['tag'] ?? 'Tag', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(insight['text'] ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, height: 1.3)),
                        const SizedBox(height: 12),
                        Text(insight['explanation'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87, height: 1.5)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(Icons.analytics_rounded, size: 16, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text('Confidence Level', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (confidence / 100).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${confidence.toInt()}%', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: isDark ? Colors.white12 : Colors.black12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(icon: Icon(Icons.thumb_up_alt_outlined, size: 20, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => _showActionSnackbar('Insight marked as helpful.', isDark)),
                            IconButton(icon: Icon(Icons.thumb_down_alt_outlined, size: 20, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => _showActionSnackbar('Insight marked as unhelpful.', isDark)),
                            IconButton(icon: Icon(Icons.bookmark_border_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => _showActionSnackbar('Insight bookmarked.', isDark)),
                          ],
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

  Widget _buildActionsTab(List<dynamic> actions, bool isDark) {
    if (actions.isEmpty) return _buildEmptyState('No actions generated.', Icons.task_alt_rounded, isDark);

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: kToolbarHeight + 80, left: 20, right: 20, bottom: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          if (actions[index] is! Map) return const SizedBox.shrink();
          final action = Map<String, dynamic>.from(actions[index] as Map);
          final priority = action['priority']?.toString() ?? 'P3';
          
          Color priorityColor = Colors.grey;
          if (priority == 'P1') priorityColor = AppColors.darkRed;
          if (priority == 'P2') priorityColor = AppColors.darkAmber;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              curve: Curves.easeOutCubic,
              child: FadeInAnimation(
                child: _buildGlassCard(
                  context,
                  isDark,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                              ),
                              child: Center(child: Text('${action['rank'] ?? index + 1}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(action['title'] ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.15), 
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: priorityColor.withOpacity(0.5)),
                              ),
                              child: Text(priority, style: TextStyle(color: priorityColor, fontWeight: FontWeight.w900, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(action['description'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87, height: 1.5)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02), 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.track_changes_rounded, size: 20, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Expected: ${action['expected_outcome'] ?? "-"}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => _showActionSnackbar('Action item marked as done.', isDark),
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                            label: const Text('MARK AS DONE'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
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

  Widget _buildExecutionTab(Map<String, dynamic> execution, bool isDark) {
    if (execution.isEmpty) return _buildEmptyState('No execution data available.', Icons.terminal_rounded, isDark);

    // Null and Type Safety Checks
    final email = execution['email'] is Map ? execution['email'] as Map<String, dynamic> : {};
    final crm = execution['crm_update'] is Map ? execution['crm_update'] as Map<String, dynamic> : {};
    final dashboard = execution['dashboard_update'] is Map ? execution['dashboard_update'] as Map<String, dynamic> : {};

    return ListView(
      padding: const EdgeInsets.only(top: kToolbarHeight + 80, left: 20, right: 20, bottom: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionTitle('Dashboard Impact', Icons.dashboard_customize_rounded),
        _buildGlassCard(
          context,
          isDark,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(dashboard['metric_name'] ?? 'Metric', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('BEFORE', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(dashboard['before_value'] ?? '-', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_rounded, color: Theme.of(context).primaryColor),
                    ),
                    Column(
                      children: [
                        Text('AFTER', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(dashboard['after_value'] ?? '-', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (dashboard['direction'] == 'up' ? AppColors.darkAccent : AppColors.darkRed).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dashboard['direction'] == 'up' ? '▲' : '▼'} ${dashboard['change_percent'] ?? "0%"}',
                    style: TextStyle(
                      color: dashboard['direction'] == 'up' ? AppColors.darkAccent : AppColors.darkRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        
        const SizedBox(height: 32),
        _buildSectionTitle('Automated Email Draft', Icons.mark_email_read_rounded),
        _buildGlassCard(
          context,
          isDark,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('To: ', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                    Text(email['to'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Subject: ${email['subject'] ?? ""}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 16),
                Text(email['body'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
              ],
            ),
          ),
        ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 32),
        _buildSectionTitle('CRM Record Update', Icons.sync_alt_rounded),
        _buildGlassCard(
          context,
          isDark,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(8)),
                  child: Text('Type: ${crm['record_type'] ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.darkRed.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkRed.withOpacity(0.2))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BEFORE', style: TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text(crm['before'].toString(), style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.darkAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkAccent.withOpacity(0.2))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AFTER', style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Text(crm['after'].toString(), style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildRawSignalsTab(List<dynamic> signals, bool isDark) {
    if (signals.isEmpty) return _buildEmptyState('No signals extracted.', Icons.data_array_rounded, isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: kToolbarHeight + 80, left: 20, right: 20, bottom: 20),
      physics: const BouncingScrollPhysics(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: signals.map((signal) {
          final isNumber = signal['signal_type'] == 'number' || signal['signal_type'] == 'percentage';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isNumber ? Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isNumber ? Theme.of(context).primaryColor.withOpacity(0.5) : (isDark ? Colors.white12 : Colors.black12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNumber) ...[
                  Icon(Icons.numbers_rounded, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  signal['text'] ?? '',
                  style: TextStyle(
                    color: isNumber ? Theme.of(context).primaryColor : (isDark ? Colors.white : Colors.black),
                    fontWeight: isNumber ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fade().scale(curve: Curves.easeOutBack);
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}