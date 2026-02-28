import 'package:flutter/material.dart';
import 'package:translate/src/features/auth/presentation/screens/auth_gate.dart';

// Removed Hardcoded Theme Constants

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Bridge the Gap',
      'subtitle':
          'Connect with communities worldwide. Break language barriers instantly.',
      'icon': Icons
          .public_rounded, // Using Icons instead of images for cleaner look
    },
    {
      'title': 'Voice of the People',
      'subtitle':
          'Translate distinct dialects and slang that standard apps miss.',
      'icon': Icons.record_voice_over_rounded,
    },
    {
      'title': 'Earn & Climb',
      'subtitle':
          'Contribute translations, earn points, and top the community leaderboard.',
      'icon': Icons.emoji_events_rounded,
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background decorative circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final pageData = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon / Illustration Area
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        pageData['icon'],
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Text Content
                    Text(
                      pageData['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pageData['subtitle'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Navigation Area
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next / Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AuthGate(),
                        ),
                      );
                    } else {
                      _onNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
