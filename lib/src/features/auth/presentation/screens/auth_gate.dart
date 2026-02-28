import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/core/reusables/auth_button.dart'
    hide kAccentColor, kBackgroundColor, kPrimaryColor;
import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

// Removed Hardcoded Theme Constants

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      debugPrint("DEBUG: Attempting Google Sign In...");
      await authProvider.signInWithGoogle();
      debugPrint("DEBUG: Google Sign In Success!");

      if (context.mounted) {
        context.go('/');
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
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary, // Blue branding background
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
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.05),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.g_translate_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GoTranslate',
                        style: TextStyle(
                          fontSize: 36,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Break language barriers instantly.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.8),
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
                    horizontal: 30.0,
                    vertical: 40.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's get started",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Sign in to save your translations and join the community.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const Spacer(),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return authProvider.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                )
                              : AuthButton(
                                  text: 'Continue with Google',
                                  isPrimary: true,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
