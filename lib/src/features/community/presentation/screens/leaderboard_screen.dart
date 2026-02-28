import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:translate/src/core/config/constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Leaderboard",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instanceFor(
                  app: Firebase.app(),
                  databaseId: TRANSLATION_FIRESTORE_DB_ID,
                )
                .collection('users')
                .orderBy('points', descending: true)
                .limit(50)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No data"));

          return CustomScrollView(
            slivers: [
              // --- TOP 3 PODIUM ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: docs.isNotEmpty
                      ? _buildPodium(context, docs)
                      : const SizedBox(),
                ),
              ),

              // --- LIST TITLE ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "TOP CONTRIBUTORS",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // --- REST OF LIST (Rank 4+) ---
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final actualIndex = index + 3; // Skip top 3
                  if (actualIndex >= docs.length) return null;

                  final data = docs[actualIndex].data() as Map<String, dynamic>;
                  return _buildRankTile(context, actualIndex + 1, data);
                }, childCount: (docs.length > 3) ? docs.length - 3 : 0),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<QueryDocumentSnapshot> docs) {
    // Safe accessors
    Map<String, dynamic>? first = docs.isNotEmpty
        ? docs[0].data() as Map<String, dynamic>
        : null;
    Map<String, dynamic>? second = docs.length > 1
        ? docs[1].data() as Map<String, dynamic>
        : null;
    Map<String, dynamic>? third = docs.length > 2
        ? docs[2].data() as Map<String, dynamic>
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _buildPodiumItem(
            context,
            2,
            second,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        if (first != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildPodiumItem(
              context,
              1,
              first,
              size: 110,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        if (third != null)
          _buildPodiumItem(
            context,
            3,
            third,
            size: 80,
            color: const Color(0xFFCD7F32),
          ), // Bronze
      ],
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    int rank,
    Map<String, dynamic> data, {
    required double size,
    required Color color,
  }) {
    final name = data['displayName'] ?? 'User';
    final points = data['points'] ?? 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                border: Border.all(color: color, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).shadowColor.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  "$rank",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size + 20,
          child: Text(
            name.split(' ')[0], // First name only
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          "$points pts",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRankTile(
    BuildContext context,
    int rank,
    Map<String, dynamic> data,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            "#$rank",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          data['displayName'] ?? 'User',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${data['points'] ?? 0} pts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
