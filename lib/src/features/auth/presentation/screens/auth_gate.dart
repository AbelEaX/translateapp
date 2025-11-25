import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/core/reusables/auth_button.dart' hide kAccentColor, kBackgroundColor, kPrimaryColor;
import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:translate/src/features/translation/presentation/screens/app_shell.dart';

// Theme Constants (Cool & Consistent)
const Color kPrimaryBlue = Color(0xFF1E3A8A);
const Color kAmberAccent = Colors.amber;
const Color kBackgroundColor = Color(0xFFF9FAFB);

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      debugPrint("DEBUG: Attempting Google Sign In...");
      await authProvider.signInWithGoogle();
      debugPrint("DEBUG: Google Sign In Success!");

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppShell()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("DEBUG: GOOGLE SIGN IN ERROR: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign in failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue, // Blue branding background
      body: Stack(
        children: [
          // Decorative Circle (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Column(
            children: [
              // --- Top Section: Branding ---
              Expanded(
                flex: 4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: const Icon(Icons.g_translate_rounded,
                            color: kAmberAccent, size: 64),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'GoTranslate',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Break language barriers instantly.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Bottom Section: Action ---
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 40.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Let's get started",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Sign in to save your translations and join the community.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                      const Spacer(),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return authProvider.isLoading
                              ? const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryBlue))
                              : AuthButton(
                            text: 'Continue with Google',
                            isPrimary: true,
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: Colors.white,
                            onPressed: () => _handleGoogleSignIn(context),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
