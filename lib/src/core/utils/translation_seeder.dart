import 'package:cloud_firestore/cloud_firestore.dart';import 'package:firebase_core/firebase_core.dart';
import 'package:translate/src/core/config/constants.dart';

class TranslationSeeder {
  // Helper to get the correct custom DB
  FirebaseFirestore get _firestore {
    try {
      final app = Firebase.app();
      return FirebaseFirestore.instanceFor(
        app: app,
        databaseId: TRANSLATION_FIRESTORE_DB_ID,
      );
    } catch (e) {
      return FirebaseFirestore.instance;
    }
  }

  Future<void> seedTranslations() async {
    final collection = _firestore.collection('translations');

    final dummyTranslations = [
      {
        'userId': 'system_seeder',
        'sourceText': 'Hello friend',
        'translatedText': 'Gyebale ko munange',
        'sourceLang': 'English',
        'targetLang': 'Luganda',
        'context': 'Casual greeting',
        'dialect': 'Central',
        'status': 'Approved',
        'score': 5,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'system_seeder',
        'sourceText': 'Water is life',
        'translatedText': 'Amaizi nigo magara',
        'sourceLang': 'English',
        'targetLang': 'Runyankole',
        'context': 'Proverb',
        'dialect': 'Western',
        'status': 'Approved',
        'score': 12,
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'system_seeder',
        'sourceText': 'Good morning',
        'translatedText': 'Wasuze otya',
        'sourceLang': 'English',
        'targetLang': 'Luganda',
        'context': 'Morning greeting',
        'dialect': 'Central',
        'status': 'Pending',
        'score': 2,
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    for (var data in dummyTranslations) {
      await collection.add(data);
      print('Seeded translation: ${data['translatedText']}');
    }
    print('--- TRANSLATION SEEDING COMPLETE ---');
  }
}
