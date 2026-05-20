import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/analysis_provider.dart';
import '../core/colors.dart';
import 'results_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search domain or severity...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(historyProvider.notifier).search('');
                    },
                  ),
                ),
                onChanged: (val) {
                  ref.read(historyProvider.notifier).search(val);
                },
              )
            : Text('Analysis History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          _buildActionIcon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            isDark,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(historyProvider.notifier).search('');
                }
              });
            },
          ),
          const SizedBox(width: 8),
          _buildActionIcon(
            Icons.filter_list_rounded,
            isDark,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Filters: Domain & Severity sorting coming soon.'),
                  backgroundColor: AppColors.darkAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Background Elements
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkBlue.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.darkPurple.withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ],
          SafeArea(
            bottom: false,
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) return _buildEmptyState(context, isDark);
                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          curve: Curves.easeOutCubic,
                          child: FadeInAnimation(
                            child: Dismissible(
                              key: Key(item.runId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.darkRed,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
                              ),
                              onDismissed: (_) {
                                ref.read(historyProvider.notifier).deleteItem(item.runId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Analysis deleted from history.'),
                                    backgroundColor: isDark ? Colors.white12 : Colors.black87,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              child: _buildHistoryCard(context, item, isDark),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading history')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, bool isDark, {required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen(runId: item.runId)));
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.description_outlined, color: isDark ? Colors.white : Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.domain, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(DateFormat('MMMM d, yyyy • h:mm a').format(item.createdAt), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.bookmarked) ...[
                        const Icon(Icons.bookmark_rounded, size: 24, color: AppColors.darkAmber),
                        const SizedBox(height: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.getSeverityColor(item.severity, isDark).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.getSeverityColor(item.severity, isDark).withOpacity(0.5)),
                        ),
                        child: Text(
                          item.severity.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.getSeverityColor(item.severity, isDark),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 100, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 24),
          Text('No History Found', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Your past analyses will appear here.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}
