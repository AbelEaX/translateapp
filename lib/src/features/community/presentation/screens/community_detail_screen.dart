import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/providers/navigation_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

class CommunityDetailScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // --- 1. IMMERSIVE HEADER ---
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Theme.of(context).colorScheme.primary),
                  if (community.profilePictureUrl != null)
                    Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        community.profilePictureUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).colorScheme.scrim.withValues(alpha: 0.8),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2),
                            backgroundImage: community.profilePictureUrl != null
                                ? NetworkImage(community.profilePictureUrl!)
                                : null,
                            child: community.profilePictureUrl == null
                                ? Icon(
                                    Icons.groups_rounded,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          community.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.public,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Language Code: ${community.languageCode.toUpperCase()}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. ACTION BAR & DESCRIPTION ---
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(
                          context,
                          '${community.memberCount}',
                          'Members',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        _buildStatColumn(context, 'Active', 'Status'),

                        Consumer<CommunityFeedProvider>(
                          builder: (context, provider, _) {
                            final currentCommunityState = provider
                                .allCommunities
                                .firstWhere(
                                  (c) => c.id == community.id,
                                  orElse: () => community,
                                );
                            final isJoined = currentCommunityState.isJoined;

                            return InkWell(
                              onTap: () {
                                if (isJoined) {
                                  provider.leaveCommunity(community.id);
                                } else {
                                  provider.joinCommunity(community.id);
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isJoined
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest
                                      : Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [],
                                ),
                                child: Text(
                                  isJoined ? 'Joined' : 'Join Now',
                                  style: TextStyle(
                                    color: isJoined
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    Text(
                      'About Community',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      community.description.isNotEmpty
                          ? community.description
                          : 'No description provided.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. SECTION HEADER ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Recent Contributions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. FILTERED FEED ---
          Consumer<CommunityFeedProvider>(
            builder: (context, provider, child) {
              final communityTranslations = provider.translations.where((t) {
                final tLang = t.targetLang.trim().toLowerCase();
                final tDialect = t.dialect.trim().toLowerCase();
                final cCode = community.languageCode.trim().toLowerCase();
                final cName = community.name.trim().toLowerCase();

                bool codeMatch = tLang.isNotEmpty && tLang == cCode;
                bool nameMatch = tLang.isNotEmpty && cName.contains(tLang);
                bool dialectMatch =
                    tDialect.isNotEmpty && cName.contains(tDialect);

                return codeMatch || nameMatch || dialectMatch;
              }).toList();

              if (communityTranslations.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No translations yet.",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Join and be the first to contribute!",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // [CHANGED] allowComments is set to true here because we are
                  // physically viewing the translation INSIDE the community detail screen.
                  return TranslationCard(
                    entry: communityTranslations[index],
                    allowComments: true,
                  );
                }, childCount: communityTranslations.length),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Floating CTA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 1. Close the Detail Screen
          Navigator.pop(context);

          // 2. Switch the main tab to "Submit" (Index 1)
          Provider.of<NavigationProvider>(context, listen: false).setIndex(1);
        },
        label: const Text(
          'Contribute',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_comment_rounded),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 4,
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
