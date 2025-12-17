import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/post_card.dart';
import '../helpers/app_theme.dart';
import '../helpers/posts_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider(''));
    final bookmarkedIds = ref.watch(bookmarksProvider);

    return postsAsync.when(
      data: (posts) {
        final bookmarkedPosts = posts
            .where((post) => bookmarkedIds.contains(post.id))
            .toList();

        if (bookmarkedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: AppTheme.bookmarksEmptyIcon,
                ),
                const SizedBox(height: 18),
                const Text(
                  'No tienes favoritos aún.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toca el icono de marcador en una noticia para guardarla aquí.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: bookmarkedPosts.length,
          itemBuilder: (context, index) {
            final post = bookmarkedPosts[index];

            return TweenAnimationBuilder<double>(
              key: ValueKey(post.id),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 40)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: PostCard(post: post),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          const Center(child: Text('Error al cargar favoritos.')),
    );
  }
}
