import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';

import 'package:translate/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:translate/src/features/community/presentation/screens/leaderboard_screen.dart';
import 'package:translate/src/features/translation/presentation/screens/contributions_screen.dart';

// Import Entity & Model
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';

// Import Sub-Screens
import 'personal_info_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserEntity> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile();
  }

  // Helper to get the current UID safely
  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<UserEntity> _fetchUserProfile() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return const UserModel(id: 'guest', displayName: 'Guest', points: 0);
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot);
      } else {
        final authUser = FirebaseAuth.instance.currentUser;
        return UserModel(
          id: userId,
          displayName: authUser?.displayName ?? 'New User',
          email: authUser?.email,
          points: 0,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return const UserModel(id: 'error', displayName: 'Error', points: 0);
    }
  }

  // --- SIGN OUT LOGIC ---

  void _handleSignOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signOut();
      // Note: The AuthGate (if used in main.dart) will automatically redirect
      // to LoginScreen when the user state becomes null.
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error signing out: $e")));
      }
    }
  }

  // [ADDED] Confirmation Dialog
  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Sign Out",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            "Are you sure you want to log out of your account?",
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(ctx).colorScheme.onSurface,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                _handleSignOut(context); // Perform sign out
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<UserEntity>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return _buildProfileContent(context, snapshot.data!);
          } else {
            return const Center(child: Text('No User Data Found'));
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserEntity user) {
    final String userName = user.displayName ?? 'User';
    final int userPoints = user.points;
    final String profileImageLetter = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : '?';

    // Get photo URL from Auth
    final authUser = FirebaseAuth.instance.currentUser;
    final String? photoUrl = authUser?.photoURL;

    return Column(
      children: [
        // --- HEADER SECTION (Immersive Gradient with Curve) ---
        Container(
          padding: const EdgeInsets.only(
            top: 60,
            bottom: 40,
            left: 20,
            right: 20,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              // --- AVATAR ---
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 3,
                  ), // Amber Ring
                  image: photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl == null
                    ? Center(
                        child: Text(
                          profileImageLetter,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                userName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Points Badge (Glassmorphic Pill)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$userPoints Points',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- MENU ITEMS ---
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            children: [
              _buildSectionHeader("Account"),
              _buildCleanMenuItem(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Personal Info',
                onTap: () =>
                    _navigateTo(context, PersonalInfoScreen(user: user)),
              ),
              _buildCleanMenuItem(
                context,
                icon: Icons.history_edu_rounded,
                title: 'My Contributions',
                onTap: () {
                  _navigateTo(context, const MyContributionsScreen());
                },
              ),

              const SizedBox(height: 20),
              _buildSectionHeader("App Settings"),
              _buildCleanMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'General Settings',
                onTap: () => _navigateTo(context, const SettingsScreen()),
              ),
              _buildCleanMenuItem(
                context,
                icon: Icons.headset_mic_outlined,
                title: 'Support',
                onTap: () => _navigateTo(context, const SupportScreen()),
              ),

              const SizedBox(height: 20),
              _buildSectionHeader("Legal & More"),
              _buildCleanMenuItem(
                context,
                icon: Icons.leaderboard_outlined,
                title: 'Leaderboard',
                onTap: () {
                  _navigateTo(context, const LeaderboardScreen());
                },
              ),
              _buildCleanMenuItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Policy',
                onTap: () => _navigateTo(context, const PrivacyPolicyScreen()),
              ),

              const SizedBox(height: 30),

              _buildCleanMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Sign out',
                isDestructive: true,
                // [CHANGED] Now triggers dialog
                onTap: () => _showSignOutConfirmation(context),
              ),

              // Version Text
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "v1.0.0",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Updated to be "Clean" - No Shadows, Border styling, consistent radii
  Widget _buildCleanMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16), // Slightly more rounded
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ), // Better touch target
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                // Trailing Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
