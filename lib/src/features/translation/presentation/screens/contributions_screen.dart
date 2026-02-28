import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:translate/src/core/config/constants.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

class MyContributionsScreen extends StatelessWidget {
  const MyContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Contributions",
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
      body: user == null
          ? const Center(child: Text("Please sign in to view contributions"))
          : StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instanceFor(
                        app: Firebase.app(),
                        databaseId: TRANSLATION_FIRESTORE_DB_ID,
                      )
                      .collection('translations')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
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
                        Icon(
                          Icons.history_edu_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No contributions yet.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Go to the Submit tab to start!",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
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
