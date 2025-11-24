import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- 0. THEME AND COLORS ---
const Color kPrimaryColor = Color(0xFF4C579E); // Main deep indigo/purple
const Color kBackgroundColor = Color(0xFF2C2A4A); // Dark background for Auth/Headers
const Color kAccentColor = Color(0xFFE5B55A); // Mock accent color for lines/dots (Orange/Gold)
const Color kSecondaryAccentColor = Color(0xFFFF9800); // Orange for Google button/Chat
const Color kErrorColor = Colors.red;

// --- 1. DATA MODEL (Kept the same) ---
class TranslationSubmission {
  final String id;
  final String title;
  final String sourceLanguage;
  final String targetLanguage;
  final String content;
  final String status;
  final DateTime submissionDate;

  TranslationSubmission({
    required this.id,
    required this.title,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.content,
    required this.status,
    required this.submissionDate,
  });
}

// Dummy data for Community Feed
class CommunityPost {
  final String name;
  final String localText;
  final String englishText;
  final String timeAgo;
  final String imageUrl;
  final int votes;

  CommunityPost({
    required this.name,
    required this.localText,
    required this.englishText,
    required this.timeAgo,
    required this.imageUrl,
    required this.votes,
  });
}

final List<CommunityPost> dummyCommunityPosts = [
  CommunityPost(
    name: 'Ojok Denis',
    localText: 'Itye ningo?',
    englishText: 'How are you?',
    timeAgo: '5 minutes ago',
    imageUrl: 'assets/3.jpg',
    votes: 2,
  ),
  CommunityPost(
    name: 'Amongi Edna',
    localText: 'ngo aber?',
    englishText: "What's good?",
    timeAgo: '24 minutes ago',
    imageUrl: 'assets/1.png',
    votes: 3,
  ),
  CommunityPost(
    name: 'Henry Quill',
    localText: 'Ka iberi?',
    englishText: 'Is it true?',
    timeAgo: '1 hour ago',
    imageUrl: 'assets/Acholi.jpg',
    votes: 1,
  ),
];

// --- 2. DUMMY DATA (Kept the same) ---
final List<TranslationSubmission> dummySubmissions = [
  TranslationSubmission(
    id: 'SUB-001',
    title: 'Common Greetings in Acholi',
    sourceLanguage: 'English',
    targetLanguage: 'Acholi',
    content:
    'Please help translate these common phrases for a travel guide: "Hello", "Thank you", "How are you?", "My name is...", "Goodbye".',
    status: 'In Progress',
    submissionDate: DateTime.now().subtract(const Duration(days: 2)),
  ),
  TranslationSubmission(
    id: 'SUB-002',
    title: 'Luganda Market Phrases',
    sourceLanguage: 'Luganda',
    targetLanguage: 'English',
    content:
    'Need to verify this translation: "Ssebo, nsinga ntya okutuuka ku katale?" means "Sir, how do I get to the market?". Also, what is "How much is this?"',
    status: 'Completed',
    submissionDate: DateTime.now().subtract(const Duration(days: 10)),
  ),
  TranslationSubmission(
    id: 'SUB-003',
    title: 'Restaurant Menu Items',
    sourceLanguage: 'English',
    targetLanguage: 'Runyakitara',
    content:
    'Translating a local restaurant menu. Need the words for "Chicken", "Beef", "Rice", and "Water". Any help is appreciated!',
    status: 'Pending Review',
    submissionDate: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  TranslationSubmission(
    id: 'SUB-004',
    title: 'Tech Terms in Lugbara',
    sourceLanguage: 'English',
    targetLanguage: 'Lugbara',
    content:
    'How would you say "Upload a file" and "Save changes" in Lugbara? This is for a new app interface.',
    status: 'Drafting',
    submissionDate: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];


// --- 3. MAIN APP WIDGET ---
void main() {
  runApp(const TranslationApp());
}

class TranslationApp extends StatelessWidget {
  const TranslationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTranslate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        primarySwatch: const MaterialColor(
          0xFF4C579E,
          <int, Color>{
            50: Color(0xFFE8E9F1),
            100: Color(0xFFC7CADF),
            200: Color(0xFFA1A5CE),
            300: Color(0xFF7B81BD),
            400: Color(0xFF616BAE),
            500: Color(0xFF4C579E), // kPrimaryColor
            600: Color(0xFF454F96),
            700: Color(0xFF3B468C),
            800: Color(0xFF323D83),
            900: Color(0xFF242E72),
          },
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        // cardTheme: CardTheme(
        //   elevation: 4,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // ),
        // Global text field style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
      home: const SplashScreen(),
      // Define named routes for deep navigation (like from Profile menu)
      routes: {
        '/personal-info': (context) => const PersonalDetailsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/support': (context) => const SupportScreen(),
      },
    );
  }
}

// --- 4. SPLASH SCREEN (Kept the same) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 100, height: 100),
            const Text(
              'GoTranslate',
              style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. ONBOARDING SCREEN (Kept the same) ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'title': 'Bringing together societies',
      'subtitle': 'We are on a mission to extend our local languages beyond borders',
      'image_url': 'assets/4.jpg',
    },
    {
      'title': 'Well curated features for you',
      'subtitle': 'Join a community that cares about growth',
      'image_url': 'assets/3.jpg',
    },
    {
      'title': 'Cool and secure service',
      'subtitle': 'Your data is secure with our robust systems allowing you to interact safely with other users.',
      'image_url': 'assets/s.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  pageData: onboardingPages[index],
                  isLastPage: index == onboardingPages.length - 1,
                  onNext: _nextPage,
                  onBack: _previousPage,
                  currentPageIndex: index,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingPages.length,
                    (index) => DotIndicator(
                  isActive: index == _currentPage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Navigate to the authentication gate on the last page's 'Next' button tap
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentPageIndex;

  const OnboardingPage({
    super.key,
    required this.pageData,
    required this.isLastPage,
    required this.onNext,
    required this.onBack,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              image: DecorationImage(
                image: AssetImage(pageData['image_url']),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                onError: (exception, stackTrace) {
                  // Fallback for image loading error (as per image instructions)
                  // Show the icon or a colored background instead
                },
              ),
            ),
            child: isLastPage
                ? const Center(
              child: Icon(
                Icons.lock,
                size: 1,
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
                isLastPage
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _AuthButton(
                        text: 'Sign up',
                        isPrimary: true,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const AuthGate(initialIndex: 0)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _AuthButton(
                        text: 'Sign in',
                        isPrimary: false,
                        foregroundColor: Colors.deepPurple,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const AuthGate(initialIndex: 1)),
                          );
                        },
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPageIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onBack,
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
                    SizedBox(width: currentPageIndex > 0 ? 15 : 0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onNext,
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

// --- 6. AUTHENTICATION GATE (Kept the same) ---
class AuthGate extends StatefulWidget {
  final int initialIndex;
  const AuthGate({super.key, this.initialIndex = 0});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showVerificationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const VerificationModal();
      },
    );
  }

  void _authenticateAndNavigate() {
    // Navigate to the new main application shell
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80, bottom: 40),
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 100, height: 100),
                const Text(
                  'GoTranslate',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SignUpForm(onSignUp: _showVerificationModal),
                  SignInForm(onSignIn: _authenticateAndNavigate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 6.1. SIGN UP FORM ---
class SignUpForm extends StatelessWidget {
  final VoidCallback onSignUp;
  const SignUpForm({super.key, required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your full name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'E.g. Amongi Ednah'),
            ),
            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Your email here'),
            ),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: Icon(Icons.remove_red_eye, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            _AuthButton(
              text: 'Sign up',
              isPrimary: true,
              onPressed: onSignUp,
            ),
            const SizedBox(height: 15),
            _AuthButton(
              text: 'Sign Up with Google',
              isPrimary: false,
              backgroundColor: kSecondaryAccentColor,
              foregroundColor: Colors.white,
              onPressed: onSignUp,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthGate(initialIndex: 1)),
                    );
                  },
                  child: const Text('Sign in', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- 6.2. SIGN IN FORM ---
class SignInForm extends StatelessWidget {
  final VoidCallback onSignIn;
  const SignInForm({super.key, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Your email here'),
            ),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: Icon(Icons.remove_red_eye, color: Colors.grey),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showResetPasswordModal(context);
                },
                child: Text('Forgot your password',
                    style: TextStyle(color: kPrimaryColor.withOpacity(0.8))),
              ),
            ),
            const SizedBox(height: 20),
            _AuthButton(
              text: 'Continue with Google',
              isPrimary: false,
              backgroundColor: kSecondaryAccentColor,
              foregroundColor: Colors.white,
              onPressed: onSignIn,
            ),
            const SizedBox(height: 15),
            const Center(child: Text('Or', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 15),
            _AuthButton(
              text: 'Sign in',
              isPrimary: true,
              onPressed: onSignIn,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthGate(initialIndex: 0)),
                    );
                  },
                  child: const Text('Sign up', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showResetPasswordModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ResetPasswordModal();
      },
    );
  }
}

// --- 6.3. AUTH BUTTON WIDGET ---
class _AuthButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _AuthButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? (isPrimary ? kPrimaryColor : Colors.white),
          foregroundColor: foregroundColor ?? (isPrimary ? Colors.white : kPrimaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: isPrimary || backgroundColor != null
              ? BorderSide.none
              : const BorderSide(color: kPrimaryColor, width: 1),
          elevation: 2,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- 6.4. VERIFICATION MODAL ---
class VerificationModal extends StatelessWidget {
  const VerificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: kPrimaryColor, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Verify',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please enter the verification code sent to your email',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                    (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expired after 12s', style: TextStyle(color: kErrorColor)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Resend', style: TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close modal
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AppShell()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6.5. RESET PASSWORD MODAL ---
class ResetPasswordModal extends StatelessWidget {
  const ResetPasswordModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, color: kPrimaryColor, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'We will send a code to your email to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Your email here'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close reset modal
                  _showVerificationModal(context); // Show verification screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Send code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Reusing VerificationModal for the code entry step
        return const VerificationModal();
      },
    );
  }
}


// -----------------------------------------------------------
// --- 7. MAIN APPLICATION SHELL (Bottom Navigation) (New) ---
// -----------------------------------------------------------

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // Home
    TranslationListScreen(submissions: dummySubmissions), // Translations (List)
    const LikesPlaceholderScreen(), // Likes
    const ProfileScreen(), // Settings (Profile Menu)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Translations'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Likes'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// --- 8. DASHBOARD SCREEN (Home Tab Content) (New) ---
// -----------------------------------------------------------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using DefaultTabController for the nested tabs (All, Community, Rewards)
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            // Dark Header Section
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Greeting & Profile Picture
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hi Abel, How\'s it going?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: kAccentColor, size: 16),
                              const SizedBox(width: 5),
                              Text('You have a new badge from our admins',
                                  style: TextStyle(
                                      color: kAccentColor.withOpacity(0.8),
                                      fontSize: 12)),
                              const Text(' 👅', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade400,
                        backgroundImage: const AssetImage(
                            'assets/2.jpg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Translations',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Filter action triggered')),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            // Tab Bar for All / Community / Rewards
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kPrimaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Community'),
                    Tab(text: 'Rewards'),
                  ],
                ),
              ),
            ),
            // Tab Bar Content
            Expanded(
              child: TabBarView(
                children: [
                  TranslationSubmissionForm(), // Modified All tab to show submission form first (as per design)
                  const CommunityFeed(), // Community Feed
                  const RewardsPlaceholder(), // Rewards placeholder
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// --- 9. DASHBOARD TAB CONTENT (MODIFIED) ---
// -----------------------------------------------------------

// --- 9.1. TRANSLATION SUBMISSION FORM (From design) ---
class TranslationSubmissionForm extends StatelessWidget {
  const TranslationSubmissionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('To add a translation: Fill in the form below',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),

          // Local Language Input
          const Text('Local Language',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Your local language translation goes here',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 20),

          // English Translation Input
          const Text('English Translation',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Your English translation goes here',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Translation submitted for review!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit for Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Have a nice day', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 100), // Extra space for bottom nav
        ],
      ),
    );
  }
}

// --- 9.2. COMMUNITY FEED (New) ---
class CommunityFeed extends StatelessWidget {
  const CommunityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 80),
      itemCount: dummyCommunityPosts.length,
      itemBuilder: (context, index) {
        final post = dummyCommunityPosts[index];
        return CommunityPostCard(post: post);
      },
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  const CommunityPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(post.imageUrl),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(post.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.timeAgo,
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 8),
                // Local Text
                Text(
                  post.localText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 5),
                // English Translation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'English: ${post.englishText}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ),
                const SizedBox(height: 10),
                // Upvote / Downvote
                Row(
                  children: [
                    Icon(Icons.arrow_upward, color: kPrimaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text('${post.votes} votes',
                        style: const TextStyle(color: kPrimaryColor)),
                    const SizedBox(width: 15),
                    Icon(Icons.arrow_downward, color: Colors.grey.shade500, size: 16),
                    const SizedBox(width: 4),
                    Text('Downvote',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 9.3. REWARDS PLACEHOLDER (New) ---
class RewardsPlaceholder extends StatelessWidget {
  const RewardsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_border, size: 80, color: kAccentColor),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Coming soon',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}



// -----------------------------------------------------------
// --- 10. TRANSLATIONS LIST SCREEN (Refactored to be a tab) ---
// -----------------------------------------------------------
class TranslationListScreen extends StatelessWidget {
  final List<TranslationSubmission> submissions;

  const TranslationListScreen({super.key, required this.submissions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submissions'),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];
          return SubmissionCard(submission: submission);
        },
      ),
    );
  }
}

// --- 10.1. LIST ITEM WIDGET (Kept the same) ---
class SubmissionCard extends StatelessWidget {
  final TranslationSubmission submission;

  const SubmissionCard({super.key, required this.submission});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade600;
      case 'In Progress':
        return Colors.orange.shade600;
      case 'Pending Review':
        return kPrimaryColor;
      case 'Drafting':
      default:
        return Colors.indigo.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(submission.status);
    final submissionDate =
    DateFormat('MMM dd, yyyy').format(submission.submissionDate);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                TranslationDetailScreen(submission: submission),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                submission.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${submission.sourceLanguage} → ${submission.targetLanguage}',
                      style: const TextStyle(
                          fontSize: 12, color: kPrimaryColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      submission.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Submitted: $submissionDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 10.2. DETAIL SCREEN (Kept the same) ---
class TranslationDetailScreen extends StatelessWidget {
  final TranslationSubmission submission;

  const TranslationDetailScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(submission.id),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailChip(
                  icon: Icons.access_time,
                  label: submission.status,
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 10),
                _buildDetailChip(
                  icon: Icons.calendar_month,
                  label: DateFormat('MMMM dd, yyyy').format(submission.submissionDate),
                  color: Colors.grey,
                ),
              ],
            ),
            const Divider(height: 30),
            _buildInfoSection(
              context,
              'Language Pair',
              '${submission.sourceLanguage} to ${submission.targetLanguage}',
              Icons.language,
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              context,
              'Source Content',
              submission.content,
              Icons.article,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Start Translation',
                    style: TextStyle(fontSize: 16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Starting work on ${submission.id}...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87,),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------
// --- 11. PROFILE / SETTINGS SCREENS (New) ---
// -----------------------------------------------------------

// --- 11.1. PROFILE MENU SCREEN ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Dark Header Section (Profile Info)
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    const Text('Profile',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade400,
                      backgroundImage: const AssetImage(
                          'assets/2.jpg'),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amongi Edna',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: kAccentColor, size: 18),
                            const SizedBox(width: 5),
                            Text('320 points',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 80),
              children: [
                _ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Personal Info',
                    onTap: () => Navigator.of(context).pushNamed('/personal-info')),
                _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Setting',
                    onTap: () => Navigator.of(context).pushNamed('/settings')),
                _ProfileMenuItem(
                    icon: Icons.build_outlined,
                    title: 'Support',
                    onTap: () => Navigator.of(context).pushNamed('/support')),
                _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Privacy & Policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy & Policy screen')));
                    }),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Sign out',
                  color: kErrorColor,
                  onTap: () {
                    // Navigate back to auth screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.grey.shade700;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Icon(icon, color: effectiveColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    color: effectiveColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}

// --- 11.2. PERSONAL DETAILS SCREEN ---
class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context, 'Personal Info'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: const AssetImage(
                        'assets/3.jpg'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Change your photo',
                        style: TextStyle(color: kPrimaryColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Your name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
                decoration: InputDecoration(hintText: 'Amongi Edna')),

            const SizedBox(height: 20),
            const Text('Phone number', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: '+256 7853 2374')),

            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'amongiedna@gmail.com')),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Personal info saved.')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 11.3. SETTINGS SCREEN ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context, 'Setting'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Language
            const Text(
                'System Language',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: 'English',
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                items: ['English', 'French', ]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Image.network(
                            'https://flagsapi.com/GB/flat/24.png',
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.language, size: 24)),
                        const SizedBox(width: 10),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language set to $newValue')));
                },
              ),
            ),
            const SizedBox(height: 30),

            // Notification Settings
            const Text('Notification',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _NotificationToggle(title: 'New Translation', initialValue: true),
            _NotificationToggle(title: 'Messages', initialValue: true),
            _NotificationToggle(title: 'Promotions', initialValue: false),

            const SizedBox(height: 30),

            // Change Password
            const Text('Change your password',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Your current password',
                    suffixIcon: Icon(Icons.visibility))),
            const SizedBox(height: 15),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Your new password',
                    suffixIcon: Icon(Icons.visibility))),
            const SizedBox(height: 15),
            const TextField(
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Retype your new password',
                    suffixIcon: Icon(Icons.visibility))),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatefulWidget {
  final String title;
  final bool initialValue;

  const _NotificationToggle({required this.title, required this.initialValue});

  @override
  State<_NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<_NotificationToggle> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Checkbox(
            value: _isEnabled,
            onChanged: (bool? newValue) {
              setState(() {
                _isEnabled = newValue!;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${widget.title} is now ${_isEnabled ? 'enabled' : 'disabled'}')));
            },
            activeColor: kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Text(widget.title),
        ],
      ),
    );
  }
}

// --- 11.4. SUPPORT SCREEN (FAQ) ---
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(context, 'Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Call and Chat Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Frequently asked question',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            const _FAQItem(
              question: 'How do I make a translation',
              answer:
              'Click the "Home" tab, then under the "All" tab, fill in the "Local Language" and "English Translation" fields and click "Submit for Review". Follow the options on the UI or click here for the complete tutorial.',
              isInitiallyExpanded: true,
            ),
            const _FAQItem(
              question: 'How do I get more points and badges',
              answer:
              'You earn points and badges by submitting high-quality translations that are approved by the community and our admins. Participate actively in the "Community" section to gain reputation.',
            ),
            const _FAQItem(
              question: 'How can I support the platform developers',
              answer:
              'You can support the platform by providing feedback, sharing the app, and participating in beta testing programs. Donation options may be available in the future.',
            ),
            const _FAQItem(
              question: 'How do I use badges',
              answer:
              'Badges are displayed on your profile and community posts to show your expertise and contribution level. They unlock certain features and recognition within the community.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isInitiallyExpanded;

  const _FAQItem({
    required this.question,
    required this.answer,
    this.isInitiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        initiallyExpanded: isInitiallyExpanded,
        shape: const RoundedRectangleBorder(), // Remove default line
        collapsedShape: const RoundedRectangleBorder(),
        title: Text(question,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(
          isInitiallyExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: kPrimaryColor,
        ),
        children: <Widget>[
          Padding(
            padding:
            const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 11.5. LIKES PLACEHOLDER (New) ---
class LikesPlaceholderScreen extends StatelessWidget {
  const LikesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Likes'),
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 20),
            const Text('You haven\'t liked any translations yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text('Go to the Community tab to find new translations!',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Widget for secondary screen AppBars ---
PreferredSizeWidget _buildCustomAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: kBackgroundColor,
    foregroundColor: Colors.white,
    toolbarHeight: 80,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
  );
}