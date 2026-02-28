import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/data/models/community_model.dart';
// Import your constants to get the DB ID
import 'package:translate/src/core/config/constants.dart';
import 'package:firebase_core/firebase_core.dart';

class CommunitySeeder {
  // We need to make sure we get the specific 'gotranslate' database instance
  // just like you did in main.dart
  FirebaseFirestore get _firestore {
    try {
      final app = Firebase.app();
      return FirebaseFirestore.instanceFor(
        app: app,
        databaseId: TRANSLATION_FIRESTORE_DB_ID, // e.g., 'gotranslate'
      );
    } catch (e) {
      // Fallback to default if custom DB setup fails or isn't being used yet
      return FirebaseFirestore.instance;
    }
  }

  Future<void> seedCommunities() async {
    final List<Community> initialCommunities = [
      const Community(
        id: 'luganda_central',
        name: 'Luganda Central',
        description:
            'The heart of Buganda culture. Share proverbs (Enjogera), idioms, and daily translations.',
        adminId: 'system_admin',
        languageCode: 'lg',
        memberCount: 1240,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Luganda+Central&background=6C63FF&color=fff&size=200',
      ),
      const Community(
        id: 'runyankole_western',
        name: 'Runyankole Hub',
        description:
            'Connecting Western Uganda. A space for Runyankole speakers to preserve heritage.',
        adminId: 'system_admin',
        languageCode: 'nyn',
        memberCount: 850,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Runyankole+Hub&background=FF6B6B&color=fff&size=200',
      ),
      const Community(
        id: 'rukiga_highlands',
        name: 'Rukiga Highlands',
        description:
            'Preserving the unique dialect of the Bakiga people in Kigezi.',
        adminId: 'system_admin',
        languageCode: 'cgg',
        memberCount: 420,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Rukiga+Highlands&background=8B0000&color=fff&size=200',
      ),
      const Community(
        id: 'acholi_northern',
        name: 'Acholi Luo Hub',
        description:
            'The voice of the North. Translate and discuss Acholi literature and conversations.',
        adminId: 'system_admin',
        languageCode: 'ach',
        memberCount: 620,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Acholi+Luo&background=4ECDC4&color=fff&size=200',
      ),
      const Community(
        id: 'lango_unity',
        name: 'Lango Unity',
        description:
            'Leb Lango. A community for the Lango people to share wisdom and translations.',
        adminId: 'system_admin',
        languageCode: 'laj',
        memberCount: 580,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Lango+Unity&background=2E8B57&color=fff&size=200',
      ),
      const Community(
        id: 'alur_nebbi',
        name: 'Alur Connect',
        description: 'Connecting Alur speakers from West Nile and beyond.',
        adminId: 'system_admin',
        languageCode: 'alz',
        memberCount: 290,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Alur+Connect&background=DAA520&color=fff&size=200',
      ),
      const Community(
        id: 'lugbara_west_nile',
        name: 'Lugbarati Ti',
        description:
            'The official community for Lugbarati speakers of West Nile.',
        adminId: 'system_admin',
        languageCode: 'lgg',
        memberCount: 450,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Lugbarati&background=483D8B&color=fff&size=200',
      ),
      const Community(
        id: 'lusoga_eastern',
        name: 'Lusoga Wise',
        description:
            'For the people of Busoga. Share wisdom and translations from the East.',
        adminId: 'system_admin',
        languageCode: 'xog',
        memberCount: 530,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Lusoga+Wise&background=FFE66D&color=000&size=200',
      ),
      const Community(
        id: 'lugisu_masaba',
        name: 'Lumasaba Link',
        description: 'Celebrating the Bamasaaba culture and dialect nuances.',
        adminId: 'system_admin',
        languageCode: 'myx',
        memberCount: 310,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Lumasaba+Link&background=1A535C&color=fff&size=200',
      ),
      const Community(
        id: 'ateso_translators',
        name: 'Ateso Roots',
        description:
            'Preserving the Ateso language and Teso traditions through translation.',
        adminId: 'system_admin',
        languageCode: 'teo',
        memberCount: 280,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Ateso+Roots&background=FF9F1C&color=fff&size=200',
      ),
      const Community(
        id: 'swahili_uganda',
        name: 'Ugandan Swahili',
        description:
            'Specifically for the unique flavor of Swahili spoken in Uganda.',
        adminId: 'system_admin',
        languageCode: 'sw',
        memberCount: 1500,
        profilePictureUrl:
            'https://ui-avatars.com/api/?name=Ugandan+Swahili&background=2F2E41&color=fff&size=200',
      ),
    ];

    final collection = _firestore.collection('communities');

    for (var community in initialCommunities) {
      try {
        await collection
            .doc(community.id)
            .set(
              CommunityModel.toFirestore(community),
              SetOptions(merge: true),
            );
        print('Seeded community: ${community.name}');
      } catch (e) {
        print('Error seeding ${community.name}: $e');
        rethrow; // Re-throw to see the error in UI
      }
    }
    print('--- SEEDING COMPLETE ---');
  }
}
