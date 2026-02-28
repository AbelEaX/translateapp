import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:translate/src/features/auth/domain/entities/user_entity.dart';

class PersonalInfoScreen extends StatelessWidget {
  final UserEntity user;

  const PersonalInfoScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Provide default values if fields are null
    final displayName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : "Not set";
    final email = user.email?.isNotEmpty == true
        ? user.email!
        : "No email linked";
    final userId = user.id;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    // Fetch the photoURL directly from FirebaseAuth to ensure we get the provider's image
    final authUser = FirebaseAuth.instance.currentUser;
    final String? photoUrl = authUser?.photoURL;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Personal Info",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- AVATAR SECTION ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 3,
                      ), // Consistent Amber Ring
                      // If photoUrl exists, show the image
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    // Fallback to initials if no image
                    child: photoUrl == null
                        ? Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        : null,
                  ),
                  // Edit Icon Badge (Visual only for now)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- INFO CARD ---
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ), // Clean Border, No Shadow
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    label: "Display Name",
                    value: displayName,
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    context,
                    icon: Icons.email_outlined,
                    label: "Email Address",
                    value: email,
                  ),
                  _buildDivider(),
                  _buildInfoTile(
                    context,
                    icon: Icons.fingerprint_rounded,
                    label: "User ID",
                    value: userId,
                    isCopyable: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Helper Text
            Text(
              "To update your personal details, please contact support or use the edit button above (coming soon).",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Builder(
      builder: (context) {
        return Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
          indent: 70,
        );
      },
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Icon Pill
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Copy Action
          if (isCopyable)
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    content: Text(
                      "User ID copied to clipboard",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
