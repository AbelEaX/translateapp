import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({super.key});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController for the three tabs (All, Community, Rewards)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Widget Builders for the Custom Header Content ---

  Widget _buildTopHeader(BuildContext context) {
    // Note: Assuming a User model/provider is available for the user's name/avatar.
    // Using static data for display purposes here.
    const String userName = 'Abel';
    const String avatarPlaceholderUrl = 'https://placehold.co/40x40/4F46E5/FFFFFF/png?text=A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting Text
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName,',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                "How's it going?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Avatar
          CircleAvatar(
            backgroundImage: NetworkImage(avatarPlaceholderUrl),
            radius: 20,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeNotification() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'You have a new badge for translating a regional dialect!',
                style: TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 10, left: 16.0, right: 16.0),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search translations...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                ),
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.indigo),
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
                expandedHeight: 250.0,
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: const Color(0xFF1E3A8A),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.zero,
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 50),
                      _buildTopHeader(context),
                      _buildBadgeNotification(),
                      _buildSearchBarAndFilter(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.amber,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorWeight: 3.0,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Community'),
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
              const Center(child: Text('Rewards Center Coming Soon', style: TextStyle(color: Colors.black87))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedContent() {
    return Consumer<CommunityFeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  const Text('Failed to load translations.', style: TextStyle(fontSize: 16)),
                  Text(provider.error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.fetchTranslations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
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
                  const Icon(Icons.groups, color: Color(0xFF1E3A8A), size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Be the first to contribute!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'No community submissions yet. Head over to the Submit tab and share your knowledge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 0, bottom: 80),
          itemCount: provider.translations.length,
          itemBuilder: (context, index) {
            final entry = provider.translations[index];
            return TranslationCard(entry: entry);
          },
        );
      },
    );
  }
}

// --- Internal Widget for Community Discovery Tab ---

class _CommunityDiscoveryTab extends StatefulWidget {
  const _CommunityDiscoveryTab();

  @override
  State<_CommunityDiscoveryTab> createState() => _CommunityDiscoveryTabState();
}

class _CommunityDiscoveryTabState extends State<_CommunityDiscoveryTab> {
  late Future<List<Community>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    // FIX: Use Future.microtask to avoid "setState during build" error.
    _communitiesFuture = Future.microtask(() =>
        Provider.of<CommunityFeedProvider>(context, listen: false).fetchAllCommunities()
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityFeedProvider>(context);

    return FutureBuilder<List<Community>>(
      future: _communitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading communities: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No communities available right now.',
                  style: TextStyle(color: Colors.black54)));
        }

        final allCommunities = snapshot.data!;
        final joinedIds = provider.joinedCommunities.map((c) => c.id).toSet();

        final displayCommunities = allCommunities.map((c) {
          return c.copyWith(isJoined: joinedIds.contains(c.id));
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 0, bottom: 80, left: 16, right: 16),
          itemCount: displayCommunities.length,
          itemBuilder: (context, index) {
            final community = displayCommunities[index];
            return _buildCommunityCard(context, provider, community);
          },
        );
      },
    );
  }

  Widget _buildCommunityCard(BuildContext context, CommunityFeedProvider provider, Community community) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 4),
            Text(
              community.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (community.isJoined) {
                    provider.leaveCommunity(community);
                  } else {
                    provider.joinCommunity(community);
                  }
                  // Refresh future to update UI state
                  setState(() {
                    _communitiesFuture = provider.fetchAllCommunities();
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: community.isJoined ? Colors.red.shade700 : Colors.white,
                  backgroundColor: community.isJoined ? Colors.red.shade100 : Colors.green.shade600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: community.isJoined ? BorderSide(color: Colors.red.shade300) : BorderSide.none,
                  ),
                ),
                child: Text(
                  community.isJoined ? 'Leave' : 'Join Community',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: community.isJoined ? Colors.red.shade700 : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
