import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/domain/usecases/get_community_translations.dart';
import 'package:translate/src/features/translation/domain/usecases/update_translation_score.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';

class CommunityFeedProvider extends ChangeNotifier {
  // Dependencies
  final GetCommunityTranslations getTranslationsUseCase;
  final UpdateTranslationScore updateScoreUseCase;

  // The specific Firestore instance (for 'gotranslate' DB)
  final FirebaseFirestore firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Real-time Subscription
  StreamSubscription<List<TranslationEntry>>? _feedSubscription;

  // --- Constructor ---
  CommunityFeedProvider({
    required this.getTranslationsUseCase,
    required this.updateScoreUseCase,
    required this.firestore,
  }) {
    fetchTranslations();
  }

  // --- Search State ---
  String _searchQuery = '';
  List<TranslationEntry> _allTranslations = []; // Stores the raw, unfiltered list

  // --- State Variables ---
  List<TranslationEntry> _translations = []; // Stores the list currently shown in UI
  List<TranslationEntry> get translations => _translations;

  List<Community> _joinedCommunities = [];
  List<Community> get joinedCommunities => _joinedCommunities;

  List<Community> _allCommunities = [];
  List<Community> get allCommunities => _allCommunities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Search Logic ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      // No search? Show everything.
      _translations = List.from(_allTranslations);
    } else {
      // Filter logic
      final query = _searchQuery.toLowerCase();
      _translations = _allTranslations.where((t) {
        return t.sourceText.toLowerCase().contains(query) ||
            t.translatedText.toLowerCase().contains(query) ||
            t.context.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // --- Community Management Methods (Firestore Implementation) ---

  Future<List<Community>> fetchAllCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await firestore.collection('communities').get();
      var fetchedCommunities = querySnapshot.docs
          .map((doc) => Community.fromFirestore(doc))
          .toList();

      final user = _auth.currentUser;
      if (user != null) {
        final joinedSnapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('joined_communities')
            .get();

        final joinedIds = joinedSnapshot.docs.map((doc) => doc.id).toSet();

        fetchedCommunities = fetchedCommunities.map((c) {
          if (joinedIds.contains(c.id)) {
            return c.copyWith(isJoined: true);
          }
          return c;
        }).toList();

        _joinedCommunities = fetchedCommunities.where((c) => c.isJoined).toList();
      } else {
        _joinedCommunities = [];
      }

      _allCommunities = fetchedCommunities;
      _isLoading = false;
      notifyListeners();
      return _allCommunities;

    } catch (e) {
      _error = 'Failed to fetch communities: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<void> joinCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('joined_communities')
          .doc(communityId)
          .set({'joinedAt': FieldValue.serverTimestamp()});

      await firestore
          .collection('communities')
          .doc(communityId)
          .update({'memberCount': FieldValue.increment(1)});

      final index = _allCommunities.indexWhere((c) => c.id == communityId);
      if (index != -1) {
        final updatedCommunity = _allCommunities[index].copyWith(
          isJoined: true,
          memberCount: _allCommunities[index].memberCount + 1,
        );
        _allCommunities[index] = updatedCommunity;

        if (!_joinedCommunities.any((c) => c.id == communityId)) {
          _joinedCommunities.add(updatedCommunity);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error joining community: $e");
      _error = 'Failed to join community';
      notifyListeners();
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('joined_communities')
          .doc(communityId)
          .delete();

      await firestore
          .collection('communities')
          .doc(communityId)
          .update({'memberCount': FieldValue.increment(-1)});

      final index = _allCommunities.indexWhere((c) => c.id == communityId);
      if (index != -1) {
        final updatedCommunity = _allCommunities[index].copyWith(
          isJoined: false,
          memberCount: (_allCommunities[index].memberCount - 1).clamp(0, 999999),
        );
        _allCommunities[index] = updatedCommunity;
        _joinedCommunities.removeWhere((c) => c.id == communityId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error leaving community: $e");
      _error = 'Failed to leave community';
      notifyListeners();
    }
  }

  // --- Real-Time Data Fetching ---
  Future<void> fetchTranslations() async {
    _feedSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = await getTranslationsUseCase.call();
      _feedSubscription = stream.listen(
            (newTranslations) {
          _allTranslations = newTranslations; // 1. Store raw data
          _applySearchFilter();               // 2. Filter it based on current query
          _isLoading = false;
          _error = null;
          // notifyListeners is called inside _applySearchFilter
        },
        onError: (e) {
          _error = 'Failed to load community feed: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Error setting up feed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateScore(String translationId, String userId, int scoreChange) async {
    if (translationId.isEmpty) return;
    try {
      await updateScoreUseCase.call(
        translationId: translationId,
        userId: userId,
        scoreChange: scoreChange,
      );
    } catch (e) {
      _error = 'Failed to update vote: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _feedSubscription?.cancel();
    super.dispose();
  }
}
