import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Privacy & Policy",
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
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.security_rounded, size: 40, color: _amberAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your Privacy Matters",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Updated: November 2025",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade100,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- POLICY SECTIONS ---
            _buildSection(
              "1. Information We Collect",
              "We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent.",
              Icons.person_search_rounded,
            ),

            _buildSection(
              "2. Data Usage",
              "We use your data to improve translation accuracy and community features. We do not share any personally identifying information publicly or with third-parties, except when required to by law.",
              Icons.data_usage_rounded,
            ),

            _buildSection(
              "3. Security",
              "We protect your data within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.",
              Icons.lock_outline_rounded,
            ),

            const SizedBox(height: 20),

            // --- FOOTER ---
            Center(
              child: Text(
                "GoTranslate Inc. © 2025",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryBlue
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade600
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
