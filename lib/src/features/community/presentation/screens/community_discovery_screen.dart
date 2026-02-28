import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';

class CommunityDiscoveryScreen extends StatefulWidget {
  const CommunityDiscoveryScreen({super.key});

  @override
  State<CommunityDiscoveryScreen> createState() =>
      _CommunityDiscoveryScreenState();
}

class _CommunityDiscoveryScreenState extends State<CommunityDiscoveryScreen> {
  late Future<List<Community>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CommunityFeedProvider>(context, listen: false);
    _communitiesFuture = Future.microtask(() => provider.fetchAllCommunities());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityFeedProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover Local Communities',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Community>>(
        future: _communitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading communities: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No communities available right now.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final allCommunities = snapshot.data!;
          // Create a set of IDs for O(1) lookup
          final joinedIds = provider.joinedCommunities.map((c) => c.id).toSet();

          // Map the fetched list to reflect the current joined status from the provider
          final displayCommunities = allCommunities.map((c) {
            return c.copyWith(isJoined: joinedIds.contains(c.id));
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: displayCommunities.length,
            itemBuilder: (context, index) {
              final community = displayCommunities[index];
              return _buildCommunityCard(context, provider, community);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context,
    CommunityFeedProvider provider,
    Community community,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 10, bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    community.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                // Display member count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${community.memberCount} members',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              community.description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (community.isJoined) {
                    // FIX: Pass ID string, not object
                    provider.leaveCommunity(community.id);
                  } else {
                    // FIX: Pass ID string, not object
                    provider.joinCommunity(community.id);
                  }

                  // Force a rebuild of the FutureBuilder to refresh the list state
                  // immediately after the button press
                  setState(() {
                    _communitiesFuture = provider.fetchAllCommunities();
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: community.isJoined
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: community.isJoined
                      ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: community.isJoined
                        ? BorderSide(color: Theme.of(context).colorScheme.error)
                        : BorderSide.none,
                  ),
                ),
                child: Text(
                  community.isJoined ? 'Leave' : 'Join Community',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: community.isJoined
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onPrimary,
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
