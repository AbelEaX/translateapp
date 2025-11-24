import 'package:flutter/material.dart';// 1. Import the AuthGate
import 'package:translate/src/features/auth/presentation/screens/auth_gate.dart';
import 'package:translate/src/core/reusables/auth_button.dart' hide kAccentColor, kBackgroundColor, kPrimaryColor;

// 2. Define constants locally
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kAccentColor = Color(0xFFFF6584);
const Color kBackgroundColor = Color(0xFF2F2E41);

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
      'title': 'Translate everywhere',
      'subtitle': 'Communicate with anyone, anywhere, regardless of language barriers.',
      'image_url': 'assets/onboarding1.png',
    },
    {
      'title': 'Voice & Text',
      'subtitle': 'Seamlessly translate both voice conversations and written text.',
      'image_url': 'assets/onboarding2.png',
    },
    {
      'title': 'Secure & Private',
      'subtitle': 'Your conversations are encrypted and remain private.',
      'image_url': 'assets/onboarding3.png',
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final pageData = _pages[index];
              final isLastPage = index == _pages.length - 1;

              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        image: DecorationImage(
                          // Ensure you have these assets, or use NetworkImage for testing
                          image: AssetImage(pageData['image_url']),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          onError: (exception, stackTrace) {
                            // Handle missing asset
                          },
                        ),
                      ),
                      child: isLastPage
                          ? const Center(
                        child: Icon(
                          Icons.lock,
                          size: 100,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(4, 8),
                            )
                          ],
                        ),
                      )
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageData['title'],
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            height: 3,
                            width: 50,
                            color: kAccentColor,
                          ),
                          Text(
                            pageData['subtitle'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.white70),
                          ),
                          const Spacer(),
                          // Indicators
                          Row(
                            children: List.generate(
                              _pages.length,
                                  (index) => DotIndicator(isActive: index == _currentPage),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action Buttons
                          isLastPage
                              ? SizedBox(
                            width: double.infinity,
                            child: AuthButton(
                              text: 'Get Started',
                              isPrimary: true,
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              onPressed: () {
                                // Simplified Navigation: Just go to AuthGate
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const AuthGate()),
                                );
                              },
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentPage > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _onBack,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              SizedBox(width: _currentPage > 0 ? 15 : 0),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _onNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: const Text('Next', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
