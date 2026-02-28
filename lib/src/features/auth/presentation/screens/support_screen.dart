import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onPrimary,
          ),
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
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Our team is ready to assist you with any issues or questions about your contributions.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // --- CONTACT OPTIONS CARD ---
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    context: context,
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "Get a response within 24h",
                    actionText: "Send Email",
                    onTap: () {
                      // Launch email logic
                    },
                  ),
                  _buildDivider(context),
                  _buildContactTile(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Live Chat",
                    subtitle: "Available 9am - 5pm EAT",
                    actionText: "Start Chat",
                    onTap: () {
                      // Launch chat logic
                    },
                  ),
                  _buildDivider(context),
                  _buildContactTile(
                    context: context,
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: theme.colorScheme.secondary,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ask the Community",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Join our Discord server",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
      indent: 70,
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Action Button (Visual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
