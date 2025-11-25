import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Help & Support",
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // --- HERO ICON ---
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent_rounded, size: 50, color: _primaryBlue),
            ),
            const SizedBox(height: 24),

            Text(
              "How can we help you?",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _primaryBlue
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Our team is ready to assist you with any issues or questions about your contributions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),

            const SizedBox(height: 40),

            // --- CONTACT OPTIONS CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "Get a response within 24h",
                    actionText: "Send Email",
                    onTap: () {
                      // Launch email logic
                    },
                  ),
                  _buildDivider(),
                  _buildContactTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Live Chat",
                    subtitle: "Available 9am - 5pm EAT",
                    actionText: "Start Chat",
                    onTap: () {
                      // Launch chat logic
                    },
                  ),
                  _buildDivider(),
                  _buildContactTile(
                    icon: Icons.help_outline_rounded,
                    title: "FAQs",
                    subtitle: "Find answers instantly",
                    actionText: "View Docs",
                    onTap: () {
                      // Navigate to FAQs
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- COMMUNITY LINK ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: _amberAccent, size: 30),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ask the Community",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Join our Discord server",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 70);
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon Pill
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),

            // Action Button (Visual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _primaryBlue),
              ),
            )
          ],
        ),
      ),
    );
  }
}
