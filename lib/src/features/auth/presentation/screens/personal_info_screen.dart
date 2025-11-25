import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:translate/src/features/auth/domain/entities/user_entity.dart';

class PersonalInfoScreen extends StatelessWidget {
  final UserEntity user;

  const PersonalInfoScreen({super.key, required this.user});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    // Provide default values if fields are null
    final displayName = user.displayName?.isNotEmpty == true ? user.displayName! : "Not set";
    final email = user.email?.isNotEmpty == true ? user.email! : "No email linked";
    final userId = user.id;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    // Fetch the photoURL directly from FirebaseAuth to ensure we get the provider's image
    final authUser = FirebaseAuth.instance.currentUser;
    final String? photoUrl = authUser?.photoURL;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Personal Info",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: _amberAccent, width: 3), // Consistent Amber Ring
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
                            color: _primaryBlue
                        ),
                      ),
                    )
                        : null,
                  ),
                  // Edit Icon Badge (Visual only for now)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- INFO CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200), // Clean Border, No Shadow
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
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 70);
  }

  Widget _buildInfoTile(BuildContext context, {
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
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryBlue, size: 22),
          ),
          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Copy Action
          if (isCopyable)
            IconButton(
              icon: Icon(Icons.copy_rounded, color: Colors.grey.shade400, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: _primaryBlue,
                    content: const Text("User ID copied to clipboard"),
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
