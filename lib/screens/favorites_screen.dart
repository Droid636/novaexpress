import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/post_card.dart';
import '../helpers/app_theme.dart';
import '../helpers/posts_provider.dart';
import '../services/favorites_cache_service.dart';

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
          return _emptyFavorites();
        }
        return _favoritesList(bookmarkedPosts);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        // Si hay error, mostrar favoritos guardados en caché
        final cached = FavoritesCacheService.getFavorites();
        if (cached.isEmpty) {
          return const Center(child: Text('No hay favoritos guardados.'));
        }
        return _favoritesList(cached);
      },
    );
  }

  Widget _favoritesList(List posts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
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
  }

  Widget _emptyFavorites() {
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
}
