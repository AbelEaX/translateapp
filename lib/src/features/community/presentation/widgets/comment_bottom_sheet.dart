import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:translate/src/core/config/constants.dart';

class CommentBottomSheet extends StatefulWidget {
  final String translationId;

  const CommentBottomSheet({super.key, required this.translationId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPosting = false;

  // Replying State
  String? _replyingToCommentId;
  String? _replyingToUserName;

  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: TRANSLATION_FIRESTORE_DB_ID,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _setReplyingTo(String commentId, String userName) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUserName = userName;
    });
    // Request focus so the keyboard pops up
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = null;
    });
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (_auth.currentUser == null) return;

    setState(() => _isPosting = true);

    try {
      final user = _auth.currentUser!;
      final commentText = _commentController.text.trim();
      final currentParentId = _replyingToCommentId; // capture current state

      final commentData = {
        'text': commentText,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userImage': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'parentId': currentParentId, // Null for top-level comments
      };

      // Add the comment
      await _firestore
          .collection('translations')
          .doc(widget.translationId)
          .collection('comments')
          .add(commentData);

      // If it was a reply, optionally increment a replyCount on the parent
      if (currentParentId != null) {
        await _firestore
            .collection('translations')
            .doc(widget.translationId)
            .collection('comments')
            .doc(currentParentId)
            .update({'replyCount': FieldValue.increment(1)});
      } else {
        // Only increment the translation's commentCount for top level comments
        // or decide if replies also count towards the total comment count.
        // Usually, total count includes replies.
        await _firestore
            .collection('translations')
            .doc(widget.translationId)
            .update({
              'commentCount': FieldValue.increment(1),
              'latestCommentText': commentText,
              'latestCommentUser': user.displayName ?? 'Anonymous',
            });
      }

      _commentController.clear();
      _cancelReply();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("Error posting comment: $e");
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Made taller
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            "Discussion",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),

          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('translations')
                  .doc(widget.translationId)
                  .collection('comments')
                  .orderBy(
                    'createdAt',
                    descending: false,
                  ) // Oldest first for threads
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No comments yet.\nStart the discussion!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final Map<String, List<DocumentSnapshot>> repliesMap = {};
                final List<DocumentSnapshot> topLevelComments = [];

                // Group comments by parentId
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final parentId = data['parentId'] as String?;

                  if (parentId == null) {
                    topLevelComments.add(doc);
                  } else {
                    repliesMap.putIfAbsent(parentId, () => []).add(doc);
                  }
                }

                // Reverse top level so newest are at the top, but replies remain chronological
                final sortedTopLevel = topLevelComments.reversed.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedTopLevel.length,
                  itemBuilder: (context, index) {
                    final doc = sortedTopLevel[index];
                    final replies = repliesMap[doc.id] ?? [];
                    return _buildThread(doc, replies);
                  },
                );
              },
            ),
          ),

          // Replying Indicator Banner
          if (_replyingToUserName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Replying to $_replyingToUserName",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyingToUserName != null
                          ? "Write a reply..."
                          : "Add a comment...",
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: _isPosting
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 18,
                          ),
                          onPressed: _postComment,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThread(
    DocumentSnapshot parentDoc,
    List<DocumentSnapshot> replies,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(parentDoc, isReply: false),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0), // Indent replies
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                children: replies.map((replyDoc) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: _buildCommentItem(replyDoc, isReply: true),
                  );
                }).toList(),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCommentItem(DocumentSnapshot doc, {required bool isReply}) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();
    final String commentId = doc.id;
    final String userName = data['userName'] ?? 'Anonymous';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 12 : 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: data['userImage'] != null
                ? NetworkImage(data['userImage'])
                : null,
            child: data['userImage'] == null
                ? Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(fontSize: isReply ? 10 : 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['text'] ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                // Reply Button (Only show on top-level comments for simple 1-level nesting)
                if (!isReply)
                  InkWell(
                    onTap: () => _setReplyingTo(commentId, userName),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Reply",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
