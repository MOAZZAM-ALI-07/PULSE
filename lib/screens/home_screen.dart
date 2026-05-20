import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          getGreeting(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('You have no new alerts.'),
                    backgroundColor: isDark ? Colors.white24 : Colors.black87,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (isDark) ...[
            Positioned(
              top: -150,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPurple.withOpacity(0.15),
                  boxShadow: [BoxShadow(color: AppColors.darkPurple.withOpacity(0.2), blurRadius: 100)],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.2, duration: const Duration(seconds: 5))
              .moveX(begin: 0, end: -30, duration: const Duration(seconds: 7)),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkAccent.withOpacity(0.1),
                  boxShadow: [BoxShadow(color: AppColors.darkAccent.withOpacity(0.2), blurRadius: 100)],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.3, duration: const Duration(seconds: 6))
              .moveY(begin: 0, end: -40, duration: const Duration(seconds: 8)),
            ),
            Positioned(
              top: 300,
              left: 50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPink.withOpacity(0.15),
                  boxShadow: [BoxShadow(color: AppColors.darkPink.withOpacity(0.2), blurRadius: 80)],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(begin: Offset.zero, end: const Offset(100, 50), duration: const Duration(seconds: 10)),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(historyProvider),
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    _buildSummaryCard(historyAsync, isDark),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Domains', style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: Icon(Icons.tune, color: isDark ? Colors.white54 : Colors.black54),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Domain filter settings opened.'),
                                backgroundColor: isDark ? Colors.white24 : Colors.black87,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDomainPills(isDark),
                    const SizedBox(height: 32),
                    Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildRecentAnalyses(historyAsync, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AsyncValue<List<AnalysisModel>> historyAsync, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF16161F), Color(0xFF0F0F18)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [AppColors.lightAccent, AppColors.lightPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : AppColors.lightAccent.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              if (isDark)
                BoxShadow(color: AppColors.darkAccent.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
            ],
          ),
          child: Stack(
            children: [
              if (isDark)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(Icons.blur_on, size: 120, color: Colors.white.withOpacity(0.05)),
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: historyAsync.when(
                  data: (history) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Analyses', '${history.length}', Icons.data_exploration, isDark),
                      _buildSummaryItem('Avg Risk', 'Med', Icons.warning_amber_rounded, isDark),
                      _buildSummaryItem('Active', '3', Icons.bolt, isDark),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (_, __) => const Text('Failed to load', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, bool isDark) {
    const color = Colors.white;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
          ),
          child: Icon(icon, color: color, size: 28),
        ).animate().scale(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        ),
        const SizedBox(height: 12),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildDomainPills(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: domains.map((domain) {
          final isSelected = selectedDomain == domain;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => selectedDomain = domain),
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
                  boxShadow: isSelected && !isDark
                      ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Text(
                  domain,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppColors.darkBg : Colors.white)
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No analyses yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
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
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutCubic,
                  child: FadeInAnimation(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ResultsScreen(runId: item.runId)),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.analytics, color: isDark ? Colors.white : Theme.of(context).primaryColor),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.domain, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt), style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.getSeverityColor(item.severity, isDark).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.getSeverityColor(item.severity, isDark).withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      item.severity.toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.getSeverityColor(item.severity, isDark),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
      error: (_, __) => const Text('Error loading history'),
    );
  }
}