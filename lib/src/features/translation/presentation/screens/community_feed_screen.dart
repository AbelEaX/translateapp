import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate/src/features/translation/presentation/providers/community_feed_provider.dart';
import 'package:translate/src/features/translation/presentation/widgets/translation_card.dart';

import '../widgets/community_feed.dart'; // Assuming TranslationCard is exported from here

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  // Fixed: Removed 'async' and 'await'.
  // This function now calls the provider's void method to restart the stream,
  // and immediately returns a resolved Future to satisfy RefreshIndicator.
  Future<void> _refreshFeed(BuildContext context) {
    context.read<CommunityFeedProvider>().fetchTranslations();
    // Return Future.value() to resolve the Future<void> required by onRefresh
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityFeedProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.translations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _refreshFeed(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.translations.isEmpty) {
          return Center(
            child: RefreshIndicator(
              onRefresh: () => _refreshFeed(context),
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No Community Submissions Yet!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text('Be the first to submit a translation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // --- Display the list of translations ---
        return RefreshIndicator(
          onRefresh: () => _refreshFeed(context),
          child: ListView.builder(
            itemCount: provider.translations.length,
            itemBuilder: (context, index) {
              final entry = provider.translations[index];
              // Assuming TranslationCard is defined in community_feed.dart
              return TranslationCard(entry: entry);
            },
          ),
        );
      },
    );
  }
}