import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for user lookup
import 'package:translate/src/features/translation/domain/entities/TranslationEntry.dart';import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class TranslationCard extends StatelessWidget {
  final TranslationEntry entry;

  const TranslationCard({super.key, required this.entry});

  String _formatCount(int count) {
    return NumberFormat.compact().format(count);
  }

  // --- NEW: Helper to fetch user name asynchronously ---
  Future<String> _fetchContributorName() async {
    if (entry.userId.isEmpty) return 'Anonymous Contributor';

    try {
      // 1. Look up the user in the 'users' collection
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(entry.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Return display name if available, otherwise a fallback
        return data['displayName'] as String? ?? 'Community Member';
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }

    // Fallback if lookup fails or doc doesn't exist
    return 'Community Member';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityFeedProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    final bool isUpvoted = entry.userVoteStatus == 1;
    final bool isDownvoted = entry.userVoteStatus == -1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: User Info & Language Badge ---
            Row(
              children: [
                // FutureBuilder for Avatar Letter
                FutureBuilder<String>(
                    future: _fetchContributorName(),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? '?';
                      final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1E3A8A),
                        child: Text(
                          letter,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- UPDATED: FutureBuilder to show real Name ---
                      FutureBuilder<String>(
                        future: _fetchContributorName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4)
                              ),
                            );
                          }

                          return Text(
                            snapshot.data ?? 'Community Member',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black87
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contributed ${timeago.format(entry.createdAt)}',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Cool Amber Language Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Text(
                    '${entry.sourceLang} → ${entry.targetLang}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- The Content with Amber Accent Line ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.sourceText,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.translatedText,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E3A8A),
                              height: 1.3
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (entry.context.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Context: ${entry.context}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // --- Footer: Voting & Actions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _handleVote(context, provider, currentUser, entry, 1),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: [
                              Icon(
                                  isUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                                  size: 18,
                                  color: isUpvoted ? Colors.amber.shade800 : Colors.grey.shade600
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatCount(entry.upvotes),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isUpvoted ? Colors.amber.shade900 : Colors.grey.shade700
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey.shade300),
                      InkWell(
                        onTap: () => _handleVote(context, provider, currentUser, entry, -1),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: [
                              Icon(
                                  isDownvoted ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
                                  size: 18,
                                  color: isDownvoted ? Colors.red.shade400 : Colors.grey.shade600
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatCount(entry.downvotes),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDownvoted ? Colors.red.shade400 : Colors.grey.shade700
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      color: Colors.grey.shade400,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      color: Colors.grey.shade400,
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleVote(BuildContext context, CommunityFeedProvider provider, User? user, TranslationEntry entry, int voteType) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please sign in to vote")));
      return;
    }
    if (entry.id != null) {
      provider.updateScore(entry.id!, user.uid, voteType);
    }
  }
}
