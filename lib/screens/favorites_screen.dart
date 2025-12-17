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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.splashBackgroundTop,
            AppTheme.splashBackgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Favoritos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 32,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: postsAsync.when(
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
          error: (_, __) {
            // Fallback a caché (NO TOCADO)
            final cached = FavoritesCacheService.getFavorites();

            if (cached.isEmpty) {
              return const Center(
                child: Text(
                  'No hay favoritos guardados.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return _favoritesList(cached);
          },
        ),
      ),
    );
  }

  // ================= LISTA =================

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

  // ================= EMPTY STATE =================

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
          const SizedBox(height: 16),
          Text(
            'Aquí aparecerán tus noticias guardadas.',
            style: TextStyle(
              color: AppTheme.splashText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '¡Guarda tus artículos favoritos para leerlos después!',
            style: TextStyle(color: AppTheme.splashLogoGlow, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
