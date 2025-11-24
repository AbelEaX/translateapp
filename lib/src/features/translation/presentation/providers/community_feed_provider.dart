import 'dart:async';
import 'package:flutter/material.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/domain/usecases/get_community_translations.dart';
import 'package:translate/src/features/translation/domain/usecases/update_translation_score.dart';
// Import the Community model to resolve type errors
import 'package:translate/src/features/community/domain/entities/community_model.dart';

// --- Placeholder Use Case Interfaces (Dependencies to be Injected) ---
// These abstract interfaces define the contract for community management.
abstract class GetAllCommunitiesUseCase {
  Future<List<Community>> call();
}
abstract class ToggleCommunityMembershipUseCase {
  Future<void> call({required String communityId, required bool isJoining});
}
// --- End Placeholder Use Cases ---


class CommunityFeedProvider extends ChangeNotifier {
  // Translation Feed Dependencies (Existing)
  final GetCommunityTranslations getTranslationsUseCase;
  final UpdateTranslationScore updateScoreUseCase;

  // Community Management Dependencies (NEW)
  final GetAllCommunitiesUseCase getAllCommunitiesUseCase;
  final ToggleCommunityMembershipUseCase toggleMembershipUseCase;

  // CRITICAL: Subscription for the real-time stream from Firestore
  StreamSubscription<List<TranslationEntry>>? _feedSubscription;

  // --- Constructor and Initialization ---
  CommunityFeedProvider({
    required this.getTranslationsUseCase,
    required this.updateScoreUseCase,
    // NEW: Add required dependencies for community management
    required this.getAllCommunitiesUseCase,
    required this.toggleMembershipUseCase,
  }) {
    // Start listening to the translation feed immediately upon initialization
    fetchTranslations();
  }

  // --- State Variables: Translation Feed ---
  List<TranslationEntry> _translations = [];
  List<TranslationEntry> get translations => _translations;

  // --- State Variables: Community Management (NEW) ---
  // The list of communities the current user has joined
  List<Community> _joinedCommunities = [];
  // FIX: Getter required by CommunityDiscoveryScreen
  List<Community> get joinedCommunities => _joinedCommunities;

  // The list of all discoverable communities (fetched once)
  List<Community> _allCommunities = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Community Management Methods (NEW) ---

  /// FIX: Method required by CommunityDiscoveryScreen
  /// Fetches all available communities.
  Future<List<Community>> fetchAllCommunities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Fetch all communities from the backend
      final all = await getAllCommunitiesUseCase.call();
      _allCommunities = all;

      // 2. Fetch or mock the current joined communities state for display logic
      // NOTE: For now, we manually mock a subset of joined communities.
      _joinedCommunities = [
        if (all.isNotEmpty) all[0].copyWith(isJoined: true),
        if (all.length > 2) all[2].copyWith(isJoined: true),
      ];

      _isLoading = false;
      notifyListeners();
      return _allCommunities;

    } catch (e) {
      _error = 'Failed to fetch all communities: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// FIX: Method required by CommunityDiscoveryScreen
  /// Adds a user to a community and updates the joined list.
  Future<void> joinCommunity(Community community) async {
    try {
      // Call Use Case to persist the change (isJoining: true)
      await toggleMembershipUseCase.call(communityId: community.id, isJoining: true);

      // Optimistically update the local state
      if (!_joinedCommunities.any((c) => c.id == community.id)) {
        // Create a copy with isJoined set to true for consistency
        _joinedCommunities = [..._joinedCommunities, community.copyWith(isJoined: true)];
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to join community: ${e.toString()}';
      notifyListeners();
    }
  }

  /// FIX: Method required by CommunityDiscoveryScreen
  /// Removes a user from a community and updates the joined list.
  Future<void> leaveCommunity(Community community) async {
    try {
      // Call Use Case to persist the change (isJoining: false)
      await toggleMembershipUseCase.call(communityId: community.id, isJoining: false);

      // Optimistically update the local state
      _joinedCommunities = _joinedCommunities.where((c) => c.id != community.id).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to leave community: ${e.toString()}';
      notifyListeners();
    }
  }

  // --- Real-Time Data Fetching (Existing Translation Feed Logic) ---

  /// Subscribes to the stream returned by the Use Case to get real-time updates.
  Future<void> fetchTranslations() async {
    // 1. Cancel any existing subscription to prevent duplicates/memory leaks
    _feedSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 2. Get the Stream from the use case (which originates in the data layer)
      final stream = await getTranslationsUseCase.call();

      // 3. Listen to the stream for real-time updates
      _feedSubscription = stream.listen(
              (newTranslations) {
            // Data event: update state with new, live data
            _translations = newTranslations;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            // Error event: handle failures in the stream
            _error = 'Failed to load community feed: $e';
            _isLoading = false;
            _translations = [];
            notifyListeners();
            debugPrint('Community Feed Stream Error: $_error');
          },
          onDone: () {
            debugPrint('Community Feed Stream completed.');
            _isLoading = false;
            notifyListeners();
          }
      );
    } catch (e) {
      // Catch synchronous errors during subscription setup
      _error = 'An error occurred setting up the feed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Voting/Score Update (Existing Logic) ---
  /// Calls the Use Case to update the score (a single write operation).
  Future<void> updateScore(String translationId, String userId, int scoreChange) async {
    if (translationId.isEmpty) return;

    try {
      // Call the use case to update the score in the backend via a transaction
      await updateScoreUseCase.call(
        translationId: translationId,
        userId: userId,
        scoreChange: scoreChange, // The delta: +1 for upvote, -1 for downvote
      );

      // The UI will automatically update because the successful transaction
      // triggers a new event on the Firestore stream, which the
      // _feedSubscription is listening to.

    } catch (e) {
      _error = 'Failed to update vote: ${e.toString()}';
      debugPrint('Update Score Error: $_error');
      // Notify listeners to potentially display an error message on the UI
      notifyListeners();
    }
  }

  // --- Cleanup (Existing Logic) ---
  @override
  void dispose() {
    // CRITICAL: Cancel the stream subscription when the provider is destroyed
    _feedSubscription?.cancel();
    super.dispose();
  }
}