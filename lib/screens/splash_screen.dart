import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'onboarding_screen.dart';
import '../core/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkAccent.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).move(
                duration: 4.seconds, curve: Curves.easeInOutSine, begin: const Offset(0, 0), end: const Offset(50, 50)).then().move(
                duration: 4.seconds, curve: Curves.easeInOutSine, begin: const Offset(50, 50), end: const Offset(0, 0)),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkPurple.withOpacity(0.2),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 5.seconds, curve: Curves.easeInOut),
          ),
          // Glass Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.darkAccent, AppColors.darkBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkAccent.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.analytics_rounded, color: AppColors.darkBg, size: 60),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05), duration: 1.5.seconds, curve: Curves.easeInOutSine)
                    .then()
                    .scale(begin: const Offset(1.05, 1.05), end: const Offset(0.9, 0.9), duration: 1.5.seconds, curve: Curves.easeInOutSine),
                
                const SizedBox(height: 40),
                
                // Typography
                Text(
                  'PULSE',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate()
                  .fadeIn(duration: 1.seconds, curve: Curves.easeOut)
                  .slideY(begin: 0.5, end: 0, duration: 1.seconds, curve: Curves.easeOutBack)
                  .shimmer(delay: 1.seconds, duration: 2.seconds, color: AppColors.darkAccent),
                  
                const SizedBox(height: 12),
                Text(
                  'INTELLIGENCE ENGINE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 8,
                    color: AppColors.darkAccent,
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
