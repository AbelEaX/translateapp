import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/features/translation/domain/entities/translation_entry.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Import the comment sheet
import 'package:translate/src/features/community/presentation/widgets/comment_bottom_sheet.dart';

class TranslationCard extends StatelessWidget {
  final TranslationEntry entry;
  final bool allowComments;

  const TranslationCard({
    super.key,
    required this.entry,
    this.allowComments = false,
  });

  String _formatCount(int count) {
    return NumberFormat.compact().format(count);
  }

  // --- Helper to fetch user name & badge asynchronously ---
  Future<Map<String, String?>> _fetchContributorInfo() async {
    if (entry.userId.isEmpty) {
      return {'name': 'Anonymous Contributor', 'badge': null};
    }

    try {
      // User profiles live in the DEFAULT Firestore database, not gotranslate.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(entry.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final name =
            (data['displayName'] as String?) ??
            (data['name'] as String?) ??
            (data['email'] as String?) ??
            'Community Member';

        final badge = data['badge'] as String?;

        return {'name': name, 'badge': badge};
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }
    return {'name': 'Community Member', 'badge': null};
  }

  // --- Helper method to open comments ---
  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(translationId: entry.id ?? ''),
    );
  }

  // --- Helper method to share content ---
  void _shareTranslation(BuildContext context) {
    final String textToShare =
        'Check out this translation on GoTranslate!\n\n'
        '${entry.sourceLang} \u2192 ${entry.targetLang}\n'
        '"${entry.sourceText}" means "${entry.translatedText}"\n\n'
        '${entry.context.isNotEmpty ? "Context: ${entry.context}\n" : ""}'
        'Join the community to learn more!';

    // ignore: deprecated_member_use
    Share.share(textToShare);
  }

  // --- Helper to handle voting ---
  void _handleVote(
    BuildContext context,
    CommunityFeedProvider provider,
    User? currentUser,
    TranslationEntry entry,
    int scoreChange,
  ) {
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please sign in to vote!")));
      return;
    }
    provider.updateScore(entry.id ?? '', currentUser.uid, scoreChange);
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
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
                FutureBuilder<Map<String, String?>>(
                  future: _fetchContributorInfo(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    final name = info?['name'] ?? '?';
                    final letter = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : '?';

                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        letter,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, String?>>(
                        future: _fetchContributorInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }

                          final info = snapshot.data;
                          final name = info?['name'] ?? 'Community Member';
                          final badge = info?['badge'];

                          return Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (badge != null && badge.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contributed ${timeago.format(entry.createdAt)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.sourceLang,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        entry.targetLang,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- The Content ---
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
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
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.translatedText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.3,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Context: ${entry.context}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 16),

            // --- Footer: Voting & Actions ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Side: Votes
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _handleVote(
                          context,
                          provider,
                          currentUser,
                          entry,
                          1,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: [
                              Icon(
                                isUpvoted
                                    ? Icons.thumb_up_rounded
                                    : Icons.thumb_up_outlined,
                                size: 18,
                                color: isUpvoted
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).iconTheme.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatCount(entry.upvotes),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isUpvoted
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      InkWell(
                        onTap: () => _handleVote(
                          context,
                          provider,
                          currentUser,
                          entry,
                          -1,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: [
                              Icon(
                                isDownvoted
                                    ? Icons.thumb_down_rounded
                                    : Icons.thumb_down_outlined,
                                size: 18,
                                color: isDownvoted
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).iconTheme.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatCount(entry.downvotes),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDownvoted
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side: Actions
                Row(
                  children: [
                    // Comment Button with Count
                    if (allowComments)
                      InkWell(
                        onTap: () => _openComments(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 22,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              if (entry.commentCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  _formatCount(entry.commentCount),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Audio coming soon!")),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () => _shareTranslation(context),
                    ),
                  ],
                ),
              ],
            ),

            // Latest Comment Preview
            if (allowComments &&
                entry.latestCommentText != null &&
                entry.latestCommentText!.isNotEmpty) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _openComments(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiny Avatar or Icon
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          (entry.latestCommentUser != null &&
                                  entry.latestCommentUser!.isNotEmpty)
                              ? entry.latestCommentUser![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "${entry.latestCommentUser ?? 'Someone'}: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: entry.latestCommentText,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
