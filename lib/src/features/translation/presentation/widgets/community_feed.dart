import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/auth/presentation/screens/profile_screen.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/community/presentation/screens/community_detail_screen.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/providers/navigation_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';
import 'package:translate/src/notifications/notification_screen.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({super.key});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  User? _currentUser;

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() {
    if (mounted) {
      setState(() {
        _currentUser = FirebaseAuth.instance.currentUser;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Widget Builders for the Custom Header Content ---

  Widget _buildTopHeader(BuildContext context) {
    final String userName = _currentUser?.displayName?.split(' ')[0] ?? 'Guest';
    final String? photoUrl = _currentUser?.photoURL;
    final String letterFallback = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName,',
                style: TextStyle(
                  color: Colors.blue.shade100,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Explore Feeds",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          // Avatar
          GestureDetector(
            onTap: () {
              Provider.of<NavigationProvider>(context, listen: false).setIndex(2);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _amberAccent, width: 2),
                color: Colors.indigo.shade300,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
                image: photoUrl != null
                    ? DecorationImage(
                  image: NetworkImage(photoUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: photoUrl == null
                  ? Center(
                child: Text(
                  letterFallback,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeNotification() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'New Badge Unlocked: Dialect Master!',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSearchBarAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 0, left: 20.0, right: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  Provider.of<CommunityFeedProvider>(context, listen: false)
                      .setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search translations...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: _primaryBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<CommunityFeedProvider>(context, listen: false)
                          .setSearchQuery('');
                      setState(() {});
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.tune_rounded, color: _primaryBlue),
              onPressed: () {
                // Handle filter action
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 280.0,
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: _primaryBlue,

                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.zero,
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 60),
                      _buildTopHeader(context),
                      _buildBadgeNotification(),
                      _buildSearchBarAndFilter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: _amberAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: _amberAccent,
                  unselectedLabelColor: Colors.blue.shade100,
                  indicatorWeight: 4.0,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  tabs: const [
                    Tab(text: 'Feed'),
                    Tab(text: 'Communities'),
                    Tab(text: 'Rewards'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedContent(),
              const _CommunityDiscoveryTab(),
              _buildRewardsPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Rewards Coming Soon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    return Consumer<CommunityFeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(color: _primaryBlue));
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.red.shade300, size: 60),
                  const SizedBox(height: 16),
                  const Text('Oops!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(provider.error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.fetchTranslations,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.translations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle
                      ),
                      child: Icon(Icons.edit_note_rounded, color: _primaryBlue, size: 60)
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Start the Conversation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No translations yet. Be the first to contribute!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, bottom: 80),
          itemCount: provider.translations.length,
          itemBuilder: (context, index) {
            final entry = provider.translations[index];

            // [ADDED] Logic to determine if user can comment in the main feed
            // We check if the user has joined a community that matches this translation's language
            final joinedCommunities = provider.joinedCommunities;
            bool canComment = false;

            if (entry.targetLang != null) {
              // Check if any joined community has this language code
              canComment = joinedCommunities.any((c) =>
              c.languageCode.toLowerCase() == entry.targetLang!.toLowerCase()
              );
            }

            return TranslationCard(
              entry: entry,
              allowComments: canComment,
            );
          },
        );
      },
    );
  }
}

// ====================================================
// INTERNAL WIDGET: Community Discovery Tab
// ====================================================

class _CommunityDiscoveryTab extends StatefulWidget {
  const _CommunityDiscoveryTab();

  @override
  State<_CommunityDiscoveryTab> createState() => _CommunityDiscoveryTabState();
}

class _CommunityDiscoveryTabState extends State<_CommunityDiscoveryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityFeedProvider>(context, listen: false)
          .fetchAllCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityFeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allCommunities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.allCommunities.isEmpty) {
          return Center(
              child: Text('Error loading communities',
                  style: TextStyle(color: Colors.grey.shade600)));
        }

        final allCommunities = provider.allCommunities;
        final joinedCommunities = provider.joinedCommunities;
        final joinedIds = joinedCommunities.map((c) => c.id).toSet();

        if (allCommunities.isEmpty) {
          return const Center(
              child: Text('No communities available right now.',
                  style: TextStyle(color: Colors.black54)));
        }

        final displayCommunities = allCommunities.map((c) {
          return c.copyWith(isJoined: joinedIds.contains(c.id));
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: displayCommunities.length,
          itemBuilder: (context, index) {
            final community = displayCommunities[index];

            final String initials = community.name.isNotEmpty
                ? community.name.split(' ').take(2).map((e) => e[0]).join().toUpperCase()
                : '?';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommunityDetailScreen(community: community),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${community.memberCount} members',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (community.isJoined)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          "Joined",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      InkWell(
                        onTap: () {
                          provider.joinCommunity(community.id);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Join",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
