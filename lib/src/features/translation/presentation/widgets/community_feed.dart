import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:translate/src/features/community/presentation/screens/community_detail_screen.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';
import 'package:translate/src/notifications/notification_screen.dart';
import 'package:translate/src/notifications/presentation/providers/notification_provider.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({super.key});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
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
      Provider.of<CommunityFeedProvider>(
        context,
        listen: false,
      ).fetchAllCommunities();
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
            child: Text(
              'Error loading communities',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final allCommunities = provider.allCommunities;
        final joinedCommunities = provider.joinedCommunities;
        final joinedIds = joinedCommunities.map((c) => c.id).toSet();

        if (allCommunities.isEmpty) {
          return Center(
            child: Text(
              'No communities available right now.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
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
                ? community.name
                      .split(' ')
                      .take(2)
                      .map((e) => e[0])
                      .join()
                      .toUpperCase()
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${community.memberCount} members',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (community.isJoined)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          "Joined",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Join",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
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

class _CommunityFeedState extends State<CommunityFeed>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Widget Builders for the Custom Header Content ---

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GoTranslate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  //color: Theme.of(context).colorScheme.onPrimary,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect, learn & Share.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: ClipOval(
                child: FirebaseAuth.instance.currentUser?.photoURL != null
                    ? Image.network(
                        FirebaseAuth.instance.currentUser!.photoURL!,
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeNotification() {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, _) {
        // Hide if no notifications exist yet
        if (notifProvider.notifications.isEmpty) return const SizedBox.shrink();

        final latest = notifProvider.notifications.first;
        final bool isUnread = !latest.isRead;

        IconData icon;
        switch (latest.type) {
          case 'upvote':
            icon = Icons.thumb_up_rounded;
          case 'comment':
            icon = Icons.chat_bubble_rounded;
          case 'badge':
            icon = Icons.stars_rounded;
          default:
            icon = Icons.notifications_active_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 4,
            left: 20,
            right: 20,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                notifProvider.markAsRead(latest.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        latest.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, right: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
        top: 0,
        left: 20.0,
        right: 20.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).shadowColor.withValues(alpha: 0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  Provider.of<CommunityFeedProvider>(
                    context,
                    listen: false,
                  ).setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search translations...',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<CommunityFeedProvider>(
                              context,
                              listen: false,
                            ).setSearchQuery('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, _) {
                  // Banner is ~72 px (12+12 padding + ~48 content).
                  // Shrink when there is nothing to show.
                  final hasNotification =
                      notifProvider.notifications.isNotEmpty;
                  final expandedHeight = hasNotification ? 320.0 : 210.0;
                  return SliverAppBar(
                    expandedHeight: expandedHeight,
                    floating: true,
                    pinned: true,
                    snap: true,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsets.zero,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -50,
                            right: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          SafeArea(
                            bottom: false,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildTopHeader(context),
                                  _buildBadgeNotification(),
                                  _buildSearchBarAndFilter(),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Theme.of(context).colorScheme.secondary,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.7),
                      indicatorWeight: 4.0,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: 'Feed'),
                        Tab(text: 'Communities'),
                        Tab(text: 'Rewards'),
                      ],
                    ),
                  ); // end SliverAppBar
                }, // end Consumer builder
              ), // end Consumer
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
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            "Rewards Coming Soon",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    return Consumer<CommunityFeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.fetchTranslations,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 60,
                    ),
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
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.5,
                    ),
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

            // Check if any joined community has this language code
            canComment = joinedCommunities.any(
              (c) =>
                  c.languageCode.toLowerCase() ==
                  entry.targetLang.toLowerCase(),
            );

            return TranslationCard(entry: entry, allowComments: canComment);
          },
        );
      },
    );
  }
}

Widget build(BuildContext context) {
  return Consumer<CommunityFeedProvider>(
    builder: (context, provider, child) {
      if (provider.isLoading && provider.allCommunities.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (provider.error != null && provider.allCommunities.isEmpty) {
        return Center(
          child: Text(
            'Error loading communities',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        );
      }

      final allCommunities = provider.allCommunities;
      final joinedCommunities = provider.joinedCommunities;
      final joinedIds = joinedCommunities.map((c) => c.id).toSet();

      if (allCommunities.isEmpty) {
        return Center(
          child: Text(
            'No communities available right now.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        );
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
              ? community.name
                    .split(' ')
                    .take(2)
                    .map((e) => e[0])
                    .join()
                    .toUpperCase()
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${community.memberCount} members',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (community.isJoined)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        "Joined",
                        style: TextStyle(
                          color: Colors.green,
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Join",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
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
