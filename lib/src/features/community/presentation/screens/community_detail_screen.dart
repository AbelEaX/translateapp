import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/community/domain/entities/community_model.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/providers/navigation_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

class CommunityDetailScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailScreen({super.key, required this.community});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // --- 1. IMMERSIVE HEADER ---
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: _primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Color/Image
                  Container(color: _primaryBlue),
                  if (community.profilePictureUrl != null)
                    Opacity(
                      opacity: 0.4,
                      child: Image.network(
                        community.profilePictureUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Gradient Overlay for readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),

                  // Centered Community Info
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40), // Offset for status bar
                        // Amber Ring Avatar
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _amberAccent, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.indigo.shade100,
                            backgroundImage: community.profilePictureUrl != null
                                ? NetworkImage(community.profilePictureUrl!)
                                : null,
                            child: community.profilePictureUrl == null
                                ? Icon(Icons.groups_rounded, size: 40, color: _primaryBlue)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          community.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Glassmorphic Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public, color: Colors.blue.shade100, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Language Code: ${community.languageCode.toUpperCase()}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
              offset: const Offset(0, -30), // Pull up slightly over the app bar
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row

                    SizedBox(height: 25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('${community.memberCount}', 'Members'),
                        Container(width: 1, height: 30, color: Colors.grey.shade200),
                        _buildStatColumn('Active', 'Status'), // Placeholder logic

                        // Dynamic Join Button
                        Consumer<CommunityFeedProvider>(
                          builder: (context, provider, _) {
                            final currentCommunityState = provider.allCommunities
                                .firstWhere((c) => c.id == community.id, orElse: () => community);
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                    color: isJoined ? Colors.grey.shade100 : _primaryBlue,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: isJoined ? [] : [
                                      BoxShadow(color: _primaryBlue.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                                    ]
                                ),
                                child: Text(
                                  isJoined ? 'Joined' : 'Join Now',
                                  style: TextStyle(
                                    color: isJoined ? Colors.grey.shade800 : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // About Section
                    Text(
                      'About Community',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryBlue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      community.description.isNotEmpty ? community.description : 'No description provided.',
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade600),
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
                  Container(width: 4, height: 24, decoration: BoxDecoration(color: _amberAccent, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Text(
                    'Recent Contributions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _primaryBlue),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. FILTERED FEED ---
          Consumer<CommunityFeedProvider>(
            builder: (context, provider, child) {
              // --- ROBUST FILTERING LOGIC ---
              final communityTranslations = provider.translations.where((t) {
                final tLang = (t.targetLang ?? '').trim().toLowerCase();
                final tDialect = (t.dialect ?? '').trim().toLowerCase();
                final cCode = community.languageCode.trim().toLowerCase();
                final cName = community.name.trim().toLowerCase();

                bool codeMatch = tLang.isNotEmpty && tLang == cCode;
                bool nameMatch = tLang.isNotEmpty && cName.contains(tLang);
                bool dialectMatch = tDialect.isNotEmpty && cName.contains(tDialect);

                return codeMatch || nameMatch || dialectMatch;
              }).toList();

              if (communityTranslations.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "No translations yet.",
                          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Join and be the first to contribute!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return TranslationCard(entry: communityTranslations[index]);
                  },
                  childCount: communityTranslations.length,
                ),
              );
            },
          ),

          // Bottom Buffer
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
        label: const Text('Contribute', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_comment_rounded),
        backgroundColor: _amberAccent,
        foregroundColor: Colors.black87,
        elevation: 4,
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
