import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the domain entity and data model
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Use UserEntity as the type returned by the Future
  late Future<UserEntity> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    // Start the asynchronous data fetching when the widget is initialized
    _userProfileFuture = _fetchUserProfile();
  }

  String get _currentUserId {
    // This safely retrieves the current user's ID.
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'anonymous_user_id';
  }

  // Data Fetching Logic (Returns UserEntity, created by UserModel.fromFirestore)
  Future<UserEntity> _fetchUserProfile() async {
    final userId = _currentUserId;
    // Targeting the 'users/{userId}' document in Firestore
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // Use the UserModel to map the snapshot into a UserEntity
        return UserModel.fromFirestore(docSnapshot);
      } else {
        // Document doesn't exist yet, create a default profile in Firestore
        final defaultUser = UserModel(
          id: userId,
          displayName: 'New User',
          points: 0,
        );
        // Create the document with default values
        await docRef.set({
          'displayName': defaultUser.displayName,
          'points': defaultUser.points,
        });
        return defaultUser;
      }
    } catch (e) {
      // Handle potential errors during fetching (e.g., network issues)
      debugPrint('Error fetching user profile: $e');
      // Return a fallback entity on error
      return const UserEntity(id: 'error', displayName: 'Error Loading Profile', points: -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Use FutureBuilder expecting the UserEntity to manage loading state
      body: FutureBuilder<UserEntity>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4C579E),
                ));
          } else if (snapshot.hasError) {
            // Error state
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (snapshot.hasData) {
            // Data successfully loaded
            final user = snapshot.data!;
            return _buildProfileContent(context, user);
          } else {
            // No data fallback
            return const Center(child: Text('No User Data Found'));
          }
        },
      ),
    );
  }

  // Widget to build the profile content using the retrieved UserEntity
  Widget _buildProfileContent(BuildContext context, UserEntity user) {
    // Determine display name and initial for the avatar
    final String userName = user.displayName ?? 'User #${user.id.substring(0, 4)}';
    final int userPoints = user.points;
    final String profileImageLetter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Column(
      children: [
        // --- Top Section: Profile Header (Dark Blue Section) ---
        Container(
          padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: const Color(0xFF1E3A8A),

          ),
          child: Column(
            children: [
              // Header Row (Close and Title)
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Profile Image/Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: const Color(0xFF1E3A8A),
                ),
                child: Center(
                  child: Text(
                    profileImageLetter, // Dynamic Initial
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // User Name (Dynamic)
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // User Points (Dynamic)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$userPoints points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- Bottom Section: Menu Items List ---
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            children: [
              _buildProfileMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Personal Info',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Personal Info')));
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.settings,
                title: 'Setting',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Settings')));
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.headset_mic_outlined,
                title: 'Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Support')));
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.policy_outlined,
                title: 'Privacy & Policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Privacy & Policy')));
                },
              ),
              const SizedBox(height: 30),
              _buildProfileMenuItem(
                context,
                icon: Icons.logout,
                title: 'Sign out',
                color: Colors.red.shade600,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign Out Action Executed')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build the interactive menu list tiles
  Widget _buildProfileMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? color,
      }) {
    final itemColor = color ?? const Color(0xFF4C579E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Material(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: itemColor, size: 24),
                const SizedBox(width: 18),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: itemColor,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}