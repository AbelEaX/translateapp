import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import '../../domain/entities/TranslationEntry.dart';

class TranslationCard extends StatelessWidget {
  final TranslationEntry entry;

  const TranslationCard({super.key, required this.entry});

  // Helper method to generate a color based on the userId for a consistent avatar look
  Color _getColorForUser(String userId) {
    // Simple hash to color logic
    final int hash = userId.hashCode;
    return Color.fromRGBO(
      (hash * 0xFF) % 256,
      (hash * 0xAA) % 256,
      (hash * 0x55) % 256,
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the card is currently voted on by the user
    final hasVoted = entry.isVotedByUser;
    final score = entry.score;

    // TODO: REPLACE THIS TEMPORARY ID with the actual authenticated user ID from Firebase Auth.
    final String currentUserId = 'temp-user-12345';

    // Generate a simple initial for the avatar
    final String userInitial = entry.userId.isNotEmpty ? entry.userId[0].toUpperCase() : '?';

    // A subtle elevation (2.0) is added to make the card stand out more.
    return Card(
      margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4.0, // Increased elevation for a more prominent card look
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Slightly increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Translator Info and Language Header (NEW ROW) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Language Header
                Text(
                  '${entry.sourceLang.toUpperCase()} > ${entry.targetLang.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
                // Translator Avatar
                Row(
                  children: [
                    Text(
                      'Translator: ${entry.userId.substring(0, 8)}...',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: _getColorForUser(entry.userId).withOpacity(0.8),
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Source Text - Uses higher contrast color and regular style
            Text(
              entry.sourceText,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal,
                color: Colors.black54, // Better contrast
              ),
            ),
            const SizedBox(height: 10),


            // --- Translated Text (MOST PROMINENT) ---
            Text(
              entry.translatedText,
              style: const TextStyle(
                fontSize: 24, // Significantly increased size for prominence
                fontWeight: FontWeight.w900, // Maximum boldness
                color: Colors.black, // Highest contrast
              ),
            ),

            const Divider(height: 15, thickness: 1),

            // --- Metadata and Voting ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Context and Dialect - Kept informative but readable
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Context: ${entry.context}',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)
                    ),
                    Text(
                        'Dialect: ${entry.dialect}',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),

                // Voting Buttons and Score
                Row(
                  children: [
                    // Upvote Button
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        // FIX: Color the upvote button if the user has voted (assuming an active vote is an upvote for visual feedback).
                        color: hasVoted ? Colors.green.shade600 : Colors.grey.shade600,
                        size: 28,
                      ),
                      onPressed: () {
                        // Intent: UPVOTE (+1). The repository handles the complex transaction
                        // logic (undoing a vote or switching a vote) to ensure the count is correct.
                        context.read<CommunityFeedProvider>().updateScore(entry.id!, currentUserId, 1);
                      },
                      tooltip: 'Accept as good translation',
                    ),

                    // Score Display
                    Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: score > 0
                            ? Colors.green.shade700
                            : (score < 0 ? Colors.red.shade700 : Colors.grey.shade700),
                      ),
                    ),

                    // Downvote Button
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        // FIX: Keep Downvote gray. Since TranslationEntry lacks a userDownvote status,
                        // we cannot visually confirm a downvote without guessing or updating the model.
                        color: Colors.grey.shade600,
                        size: 28,
                      ),
                      onPressed: () {
                        // Intent: DOWNVOTE (-1). The repository handles the complex transaction logic.
                        context.read<CommunityFeedProvider>().updateScore(entry.id!, currentUserId, -1);
                      },
                      tooltip: 'Reject as poor translation',
                    ),
                  ],
                ),
              ],
            ),
            // --- Footer: Submitted by and Time ---
            const SizedBox(height: 5),
            Text(
              'Submitted at: ${entry.createdAt.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}