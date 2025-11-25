import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _dataSaver = false;

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Settings",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Preferences"),
            const SizedBox(height: 16),

            // --- NOTIFICATIONS CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: "Push Notifications",
                    subtitle: "Receive updates about your contributions",
                    value: _pushNotifications,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
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
            _buildSectionHeader("Appearance & Data"),
            const SizedBox(height: 16),

            // --- APPEARANCE CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Dark Mode",
                    subtitle: "Reduce eye strain at night",
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
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
            _buildSectionHeader("Account Actions"),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.red.shade50,
                ),
                child: Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: _primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 70);
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        activeColor: _amberAccent,
        activeTrackColor: Colors.amber.shade100,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }
}
