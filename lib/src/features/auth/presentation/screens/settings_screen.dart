import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataSaver = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Settings",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, "Preferences"),
            const SizedBox(height: 16),

            // --- NOTIFICATIONS CARD ---
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: "Push Notifications",
                    subtitle: "Receive updates about your contributions",
                    value: _pushNotifications,
                    onChanged: (val) =>
                        setState(() => _pushNotifications = val),
                    theme: theme,
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    theme: theme,
                    icon: Icons.email_outlined,
                    title: "Email Digests",
                    subtitle: "Weekly summary of community activity",
                    value: false, // Mock value
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader(theme, "Appearance & Data"),
            const SizedBox(height: 16),

            // --- APPEARANCE CARD ---
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    theme: theme,
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    subtitle: "Reduce eye strain at night",
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    theme: theme,
                    icon: Icons.data_saver_on_outlined,
                    title: "Data Saver",
                    subtitle: "Reduce data usage for images",
                    value: _dataSaver,
                    onChanged: (val) => setState(() => _dataSaver = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader(theme, "Account Actions"),
            const SizedBox(height: 16),

            // --- DELETE ACCOUNT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Add delete logic here
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: theme.colorScheme.error.withValues(
                    alpha: 0.1,
                  ),
                ),
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outlineVariant,
      indent: 70,
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        activeTrackColor: theme.colorScheme.secondary.withValues(alpha: 0.5),
        inactiveThumbColor: theme.colorScheme.onSurfaceVariant,
        inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
