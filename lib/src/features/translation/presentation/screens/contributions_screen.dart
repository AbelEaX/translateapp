import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

class MyContributionsScreen extends StatelessWidget {
  const MyContributionsScreen({super.key});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Contributions",
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
      body: user == null
          ? const Center(child: Text("Please sign in to view contributions"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('translations')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryBlue));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "No contributions yet.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  const Text("Go to the Submit tab to start!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 30),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // Map Firestore doc to Entity
              // Assuming standard fields based on your other code
              final data = docs[index].data() as Map<String, dynamic>;
              final entry = TranslationEntry(
                id: docs[index].id,
                userId: data['userId'] ?? '',
                sourceText: data['sourceText'] ?? '',
                translatedText: data['translatedText'] ?? '',
                sourceLang: data['sourceLang'] ?? '',
                targetLang: data['targetLang'] ?? '',
                context: data['context'] ?? '',
                dialect: data['dialect'] ?? '',
                upvotes: data['upvotes'] ?? 0,
                downvotes: data['downvotes'] ?? 0,
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                userVoteStatus: 0, // Default for own view
              );

              return TranslationCard(entry: entry);
            },
          );
        },
      ),
    );
  }
}
