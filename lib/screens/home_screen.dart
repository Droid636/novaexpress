import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/posts_provider.dart';
import '../components/post_card.dart';
import '../components/news_bottom_nav_bar.dart';
import '../components/news_search_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider(_search));

    return Scaffold(
      appBar: AppBar(title: const Text('Noticias recientes')),
      body: Column(
        children: [
          NewsSearchBar(
            onSearch: (value) {
              setState(() {
                _search = value;
              });
            },
            initialValue: _search,
          ),
          Expanded(
            child: postsAsync.when(
              data: (posts) => ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => PostCard(post: posts[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NewsBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
