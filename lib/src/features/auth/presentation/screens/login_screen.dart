import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/core/reusables/auth_button.dart' hide kAccentColor, kBackgroundColor, kPrimaryColor;
import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';

// Define constants locally to match the design system
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFF2F2E41);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the provider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Section: Branding ---
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_translate, color: Colors.white, size: 80),
                    SizedBox(height: 20),
                    Text(
                      'GoTranslate',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Break language barriers instantly.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Section: Action ---
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to continue contributing to the largest open source database for Ugandan languages.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),

                    // --- Google Sign In Button ---
                    authProvider.isLoading
                        ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                        : AuthButton(
                      text: 'Sign In with Google',
                      isPrimary: true,
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        try {
                          // The Provider handles the logic and state updates
                          await authProvider.signInWithGoogle();
                          // Navigation to AppShell is handled automatically
                          // by main.dart's StreamBuilder
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Sign in failed: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // Error Message Display
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            'Error: ${authProvider.error}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
