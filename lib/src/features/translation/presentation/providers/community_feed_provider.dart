import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/domain/usecases/get_communities.dart';
import 'package:translate/src/features/community/domain/usecases/join_community.dart';
import 'package:translate/src/features/community/domain/usecases/leave_community.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';
import 'package:translate/src/features/translation/domain/usecases/get_community_translations.dart';
import 'package:translate/src/features/translation/domain/usecases/update_translation_score.dart';

class CommunityFeedProvider extends ChangeNotifier {
  // Use-cases (no direct Firebase access)
  final GetCommunityTranslations getTranslationsUseCase;
  final UpdateTranslationScore updateScoreUseCase;
  final GetCommunities getCommunitiesUseCase;
  final JoinCommunity joinCommunityUseCase;
  final LeaveCommunity leaveCommunityUseCase;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<List<TranslationEntry>>? _feedSubscription;

  CommunityFeedProvider({
    required this.getTranslationsUseCase,
    required this.updateScoreUseCase,
    required this.getCommunitiesUseCase,
    required this.joinCommunityUseCase,
    required this.leaveCommunityUseCase,
  }) {
    fetchTranslations();
  }

  // --- Search State ---
  String _searchQuery = '';
  List<TranslationEntry> _allTranslations = [];

  // --- State Variables ---
  List<TranslationEntry> _translations = [];
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
      _translations = List.from(_allTranslations);
    } else {
      final query = _searchQuery.toLowerCase();
      _translations = _allTranslations.where((t) {
        return t.sourceText.toLowerCase().contains(query) ||
            t.translatedText.toLowerCase().contains(query) ||
            t.context.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // --- Community Management (via Use-Cases) ---

  Future<List<Community>> fetchAllCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      final communities = await getCommunitiesUseCase.call(userId);

      _allCommunities = communities;
      _joinedCommunities = communities.where((c) => c.isJoined).toList();

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
      await joinCommunityUseCase.call(user.uid, communityId);

      final index = _allCommunities.indexWhere((c) => c.id == communityId);
      if (index != -1) {
        final updated = _allCommunities[index].copyWith(
          isJoined: true,
          memberCount: _allCommunities[index].memberCount + 1,
        );
        _allCommunities[index] = updated;
        if (!_joinedCommunities.any((c) => c.id == communityId)) {
          _joinedCommunities.add(updated);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error joining community: $e');
      _error = 'Failed to join community';
      notifyListeners();
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await leaveCommunityUseCase.call(user.uid, communityId);

      final index = _allCommunities.indexWhere((c) => c.id == communityId);
      if (index != -1) {
        final updated = _allCommunities[index].copyWith(
          isJoined: false,
          memberCount: (_allCommunities[index].memberCount - 1).clamp(
            0,
            999999,
          ),
        );
        _allCommunities[index] = updated;
        _joinedCommunities.removeWhere((c) => c.id == communityId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error leaving community: $e');
      _error = 'Failed to leave community';
      notifyListeners();
    }
  }

  // --- Real-Time Feed ---

  Future<void> fetchTranslations() async {
    _feedSubscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = await getTranslationsUseCase.call();
      _feedSubscription = stream.listen(
        (newTranslations) {
          _allTranslations = newTranslations;
          _applySearchFilter();
          _isLoading = false;
          _error = null;
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

  // --- Voting (Optimistic UI) ---

  Future<void> updateScore(
    String translationId,
    String userId,
    int scoreChange,
  ) async {
    if (translationId.isEmpty) return;

    final int indexAll = _allTranslations.indexWhere(
      (t) => t.id == translationId,
    );
    if (indexAll == -1) return;

    final entry = _allTranslations[indexAll];
    final int previousVote = entry.userVoteStatus;

    int upChange = 0;
    int downChange = 0;
    int newVoteStatus = 0;

    if (scoreChange == 1) {
      if (previousVote == 1) {
        upChange = -1;
        newVoteStatus = 0;
      } else if (previousVote == -1) {
        downChange = -1;
        upChange = 1;
        newVoteStatus = 1;
      } else {
        upChange = 1;
        newVoteStatus = 1;
      }
    } else if (scoreChange == -1) {
      if (previousVote == -1) {
        downChange = -1;
        newVoteStatus = 0;
      } else if (previousVote == 1) {
        upChange = -1;
        downChange = 1;
        newVoteStatus = -1;
      } else {
        downChange = 1;
        newVoteStatus = -1;
      }
    }

    final updatedEntry = entry.copyWith(
      userVoteStatus: newVoteStatus,
      upvotes: entry.upvotes + upChange,
      downvotes: entry.downvotes + downChange,
      score: entry.score + (upChange - downChange),
    );

    _allTranslations[indexAll] = updatedEntry;

    final int indexFiltered = _translations.indexWhere(
      (t) => t.id == translationId,
    );
    if (indexFiltered != -1) {
      _translations[indexFiltered] = updatedEntry;
    }

    notifyListeners();

    try {
      await updateScoreUseCase.call(
        translationId: translationId,
        userId: userId,
        scoreChange: scoreChange,
      );
    } catch (e) {
      debugPrint('Voting failed, reverting optimistic update: $e');
      _allTranslations[indexAll] = entry;
      if (indexFiltered != -1) {
        _translations[indexFiltered] = entry;
      }
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
