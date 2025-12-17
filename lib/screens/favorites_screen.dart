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
    final Set<int> bookmarkedIds = ref.watch(bookmarksProvider);

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
        body: _FavoritesBody(
          postsAsync: postsAsync,
          bookmarkedIds: bookmarkedIds,
        ),
      ),
    );
  }
}

class _FavoritesBody extends StatefulWidget {
  final AsyncValue<List<dynamic>> postsAsync;
  final Set<int> bookmarkedIds;

  const _FavoritesBody({required this.postsAsync, required this.bookmarkedIds});

  @override
  State<_FavoritesBody> createState() => _FavoritesBodyState();
}

class _FavoritesBodyState extends State<_FavoritesBody> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return widget.postsAsync.when(
      data: (posts) {
        final bookmarkedPosts = posts
            .where((post) => widget.bookmarkedIds.contains(post.id))
            .toList();

        if (bookmarkedPosts.isEmpty) {
          return _emptyFavorites();
        }
        return _favoritesList(bookmarkedPosts);
      },
      loading: () =>
          const Center(child: _CustomLoader()), // Uso del loader premium
      error: (_, __) {
        final cached = FavoritesCacheService.getFavorites();
        if (cached.isEmpty) {
          return _buildErrorState(context);
        }
        return _favoritesList(cached);
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.wifi_off,
                  size: 48,
                  color: AppTheme.splashArc,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sin conexión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.splashText,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navSelected,
              ),
              onPressed: _isRetrying
                  ? null
                  : () async {
                      setState(() => _isRetrying = true);
                      await Future.delayed(const Duration(milliseconds: 600));
                      // Corrección de acceso a ref en StatefulWidget con Riverpod
                      // Si necesitas invalidar, lo mejor es usar un Consumer o pasar ref
                      setState(() => _isRetrying = false);
                    },
              icon: _isRetrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isRetrying ? 'Cargando...' : 'Reintentar'),
            ),
          ],
        ),
      ),
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

// Copia del CustomLoader para mantener consistencia visual
class _CustomLoader extends StatefulWidget {
  const _CustomLoader();
  @override
  State<_CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<_CustomLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _controller.value * 6.28319,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              AppTheme.splashArc,
              AppTheme.navSelected,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
