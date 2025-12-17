import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/posts_provider.dart';
import '../components/post_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias recientes')),
      body: postsAsync.when(
        data: (posts) => ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
