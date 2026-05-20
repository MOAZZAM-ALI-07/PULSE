import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../core/colors.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Animated Background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [AppColors.darkBg, currentPage == 0 ? AppColors.darkPurple.withOpacity(0.2) : currentPage == 1 ? AppColors.darkAccent.withOpacity(0.2) : AppColors.darkBlue.withOpacity(0.2)]
                    : [AppColors.lightBg, AppColors.lightAccent.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          if (isDark) ...[
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkAccent.withOpacity(0.1),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ],

          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
                currentPage = index;
              });
            },
            children: [
              _buildPage(
                title: 'Turn Reports Into Decisions',
                subtitle: 'Automated intelligence pipeline for modern enterprises. Understand your data in seconds.',
                icon: Icons.auto_graph_rounded,
                isDark: isDark,
              ),
              _buildPage(
                title: 'Identify Hidden Risks',
                subtitle: 'Know what matters and why. AI highlights critical risks and hidden opportunities instantly.',
                icon: Icons.lightbulb_outline_rounded,
                isDark: isDark,
              ),
              _buildPage(
                title: 'Simulate The Future',
                subtitle: 'Take action with confidence. Simulate business impact before you execute your strategies.',
                icon: Icons.play_circle_outline_rounded,
                isDark: isDark,
              ),
            ],
          ),
          
          // Navigation & Indicators
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Theme.of(context).primaryColor,
                    dotColor: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                    dotHeight: 6,
                    dotWidth: 16,
                    expansionFactor: 4,
                  ),
                ),
                isLastPage
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 600),
                              pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Initialize'),
                      ).animate().fade().scale()
                    : IconButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
              ],
            ),
          ),
          
          // Skip Button
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Text('Skip', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required IconData icon, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
              boxShadow: [
                if (!isDark) BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Icon(icon, size: 80, color: Theme.of(context).primaryColor)
                .animate()
                .shimmer(duration: 2.seconds, delay: 500.ms),
          )
              .animate()
              .fade(duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1.2, fontWeight: FontWeight.w800),
          ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  fontSize: 18,
                  height: 1.5,
                ),
          ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
