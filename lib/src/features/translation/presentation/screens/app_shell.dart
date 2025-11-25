import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/auth/presentation/screens/profile_screen.dart';
import 'package:translate/src/features/translation/presentation/widgets/community_feed.dart';
import 'package:translate/src/features/translation/presentation/widgets/submission_form.dart';
import 'package:translate/src/features/translation/presentation/providers/navigation_provider.dart'; // Import the new provider

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  final List<Widget> _screens = const [
    CommunityFeed(),
    TranslationSubmissionForm(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to the provider for the current index
    final navProvider = Provider.of<NavigationProvider>(context);
    final selectedIndex = navProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Update the provider
          navProvider.setIndex(index);
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
