import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase.app()
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:translate/src/core/config/constants.dart'; // Import your constants

class CommentBottomSheet extends StatefulWidget {
  final String translationId;

  const CommentBottomSheet({super.key, required this.translationId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPosting = false;

  // [FIX] Helper to get the correct Custom Database Instance
  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: TRANSLATION_FIRESTORE_DB_ID, // Uses the ID from your constants
    );
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (_auth.currentUser == null) return;

    setState(() => _isPosting = true);

    try {
      final user = _auth.currentUser!;

      // [FIX] Use _firestore instead of FirebaseFirestore.instance
      await _firestore
          .collection('translations')
          .doc(widget.translationId)
          .collection('comments')
          .add({
        'text': _commentController.text.trim(),
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userImage': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            "Discussion",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
          ),
          const Divider(),

          // Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // [FIX] Use _firestore instead of FirebaseFirestore.instance
              stream: _firestore
                  .collection('translations')
                  .doc(widget.translationId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
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
                        Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "No comments yet.\nStart the discussion!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? ts = data['createdAt'] as Timestamp?;
                    final date = ts?.toDate() ?? DateTime.now();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.indigo.shade50,
                            backgroundImage: data['userImage'] != null
                                ? NetworkImage(data['userImage'])
                                : null,
                            child: data['userImage'] == null
                                ? Text((data['userName'] as String)[0].toUpperCase())
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
                                      data['userName'] ?? 'Anonymous',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeago.format(date),
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['text'] ?? '',
                                  style: const TextStyle(color: Colors.black87, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 8
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: _isPosting
                      ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
}
