// In your Firebase Service initialization logic (e.g., firestore_service.dart)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/config/constants.dart';

// 1. Get the main Firebase App instance (assuming it's already initialized)
final FirebaseApp app = Firebase.app(); // or whichever method you use to get the app

// 2. INITIALIZE THE CUSTOM DATABASE
// This is where you paste the logic, making sure to use the constant ID.
final FirebaseFirestore gotranslateDb =
FirebaseFirestore.instanceFor(app: app, databaseId: TRANSLATION_FIRESTORE_DB_ID);