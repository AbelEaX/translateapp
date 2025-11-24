import 'package:flutter/material.dart';
import 'package:translate/src/features/auth/presentation/screens/profile_screen.dart';
import 'package:translate/src/features/translation/presentation/widgets/community_feed.dart';
import 'package:translate/src/features/translation/presentation/widgets/submission_form.dart';


class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // List of screens corresponding to the bottom navigation bar items
  final List<Widget> _screens = [
    // 1. Community Feed: Shows all submitted translations (Discover)
    const CommunityFeed(),
    // 2. Submission Form: Allows users to add a new translation (Submit)
    const TranslationSubmissionForm(),
    // 3. User Profile Screen (You)
    const UserProfileScreen(), // <-- NOW DISPLAYING THE PROFILE SCREEN
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      // IndexedStack preserves the state of the inactive widgets,
      // so the CommunityFeed doesn't reload every time you switch tabs.
      body: IndexedStack(
        index: _selectedIndex,
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
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A), // Your primary color
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Use fixed for 3+ items
      ),
    );
  }
}