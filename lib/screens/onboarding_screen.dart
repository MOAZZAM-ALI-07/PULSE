import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              _buildPage(
                title: 'Turn reports into decisions instantly',
                subtitle: 'Automated intelligence pipeline for modern enterprises.',
                icon: Icons.auto_graph,
              ),
              _buildPage(
                title: 'Know what matters and why',
                subtitle: 'Identify critical risks and hidden opportunities.',
                icon: Icons.lightbulb_outline,
              ),
              _buildPage(
                title: 'Take action with confidence',
                subtitle: 'Simulate business impact before execution.',
                icon: Icons.play_circle_outline,
              ),
            ],
          ),
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
                    dotColor: Colors.grey.withOpacity(0.3),
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                isLastPage
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainLayout()),
                          );
                        },
                        child: const Text('Get Started'),
                      ).animate().fade().scale()
                    : TextButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
              ],
            ),
          ),
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                );
              },
              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).primaryColor)
              .animate()
              .fade(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
