import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/core/reusables/auth_button.dart' hide kAccentColor, kBackgroundColor, kPrimaryColor;import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
// 1. Import AppShell
import 'package:translate/src/features/translation/presentation/screens/app_shell.dart';

// Constants
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFF2F2E41);

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print("DEBUG: Attempting Google Sign In...");
      await authProvider.signInWithGoogle();
      print("DEBUG: Google Sign In Success!");

      // 2. FORCE NAVIGATION to AppShell
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppShell()),
              (route) => false, // Remove all previous routes (like Onboarding)
        );
      }

    } catch (e) {
      print("DEBUG: GOOGLE SIGN IN ERROR: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign in failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Rest of your build method stays exactly the same)
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_translate, color: Colors.white, size: 80),
                    SizedBox(height: 20),
                    Text('GoTranslate', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w300, letterSpacing: 1.2)),
                    SizedBox(height: 10),
                    Text('Break language barriers instantly.', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Let's get started", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    const Text("Sign in to save your translations and join the community.", style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                    const Spacer(),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return authProvider.isLoading // Use isSigningIn here
                            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                            : AuthButton(
                          text: 'Continue with Google',
                          isPrimary: true,
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          onPressed: () => _handleGoogleSignIn(context),
                        );
                      },
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
