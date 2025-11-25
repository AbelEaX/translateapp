import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});// Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryBlue));
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
                    color: _primaryBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: docs.isNotEmpty
                      ? _buildPodium(docs)
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
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // --- REST OF LIST (Rank 4+) ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final actualIndex = index + 3; // Skip top 3
                    if (actualIndex >= docs.length) return null;

                    final data = docs[actualIndex].data() as Map<String, dynamic>;
                    return _buildRankTile(actualIndex + 1, data);
                  },
                  childCount: (docs.length > 3) ? docs.length - 3 : 0,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> docs) {
    // Safe accessors
    Map<String, dynamic>? first = docs.length > 0 ? docs[0].data() as Map<String, dynamic> : null;
    Map<String, dynamic>? second = docs.length > 1 ? docs[1].data() as Map<String, dynamic> : null;
    Map<String, dynamic>? third = docs.length > 2 ? docs[2].data() as Map<String, dynamic> : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null) _buildPodiumItem(2, second, size: 80, color: Colors.grey.shade300),
        if (first != null) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildPodiumItem(1, first, size: 110, color: _amberAccent),
        ),
        if (third != null) _buildPodiumItem(3, third, size: 80, color: const Color(0xFFCD7F32)), // Bronze
      ],
    );
  }

  Widget _buildPodiumItem(int rank, Map<String, dynamic> data, {required double size, required Color color}) {
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
                  color: Colors.indigo.shade50,
                  border: Border.all(color: color, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold, color: _primaryBlue),
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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$rank",
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name.split(' ')[0], // First name only
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          "$points pts",
          style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRankTile(int rank, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            "#$rank",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
          ),
        ),
        title: Text(
          data['displayName'] ?? 'User',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${data['points'] ?? 0} pts",
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryBlue, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
