import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/post_card.dart';
import '../app_theme.dart';
import '../helpers/favorite_posts_provider.dart';
import '../helpers/bookmarks_provider.dart';
import '../services/favorites_cache_service.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final postsAsync = ref.watch(favoritePostsProvider);
    final Set<int> bookmarkedIds = ref.watch(bookmarksProvider);
    final user = ref.watch(authUserProvider).asData?.value;
    final isGuest = user == null;

    if (isGuest) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppTheme.splashBackgroundTop,
                    AppTheme.splashBackgroundBottom,
                  ]
                : [AppTheme.categoryBackground, AppTheme.categoryBackground],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ),
            title: Text(
              'Favoritos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: isDark ? Colors.white : AppTheme.navBackground,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : AppTheme.navBackground,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: isDark
                        ? AppTheme.splashSubtitle
                        : AppTheme.navSelected,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Inicia sesión o regístrate para guardar tus noticias favoritas y acceder a más funciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navSelected,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/login'),
                        child: const Text('Iniciar sesión'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.navSelected,
                          side: BorderSide(color: AppTheme.navSelected),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child: const Text('Registrarse'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppTheme.splashBackgroundTop, AppTheme.splashBackgroundBottom]
              : [AppTheme.categoryBackground, AppTheme.categoryBackground],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
          title: Text(
            'Favoritos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: isDark ? Colors.white : AppTheme.navBackground,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : AppTheme.navBackground,
          elevation: 0,
        ),
        body: _FavoritesBody(
          postsAsync: postsAsync,
          bookmarkedIds: bookmarkedIds,
          isDark: isDark,
        ),
      ),
    );
  }
}

// =======================================================
// BODY
// =======================================================

class _FavoritesBody extends StatefulWidget {
  final AsyncValue<List<dynamic>> postsAsync;
  final Set<int> bookmarkedIds;
  final bool isDark;

  const _FavoritesBody({
    required this.postsAsync,
    required this.bookmarkedIds,
    required this.isDark,
  });

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
      loading: () => const Center(child: _CustomLoader()),
      error: (_, __) {
        final cached = FavoritesCacheService.getFavorites();
        if (cached.isEmpty) {
          return _buildErrorState();
        }
        return _favoritesList(cached);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white12 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off, size: 48, color: AppTheme.splashArc),
            ),
            const SizedBox(height: 12),
            Text(
              'Sin conexión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : AppTheme.navBackground,
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
          duration: Duration(milliseconds: 400 + index * 40),
          builder: (_, value, child) {
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
            color: widget.isDark
                ? AppTheme.splashSubtitle
                : AppTheme.navSelected, // Mejor contraste en modo claro
          ),
          const SizedBox(height: 16),
          Text(
            'Aquí aparecerán tus noticias guardadas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? Colors.white
                  : Color(0xFF222B45), // Texto más oscuro en modo claro
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Guarda tus artículos favoritos para leerlos después!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: widget.isDark
                  ? AppTheme.splashSubtitle
                  : Color(0xFF3578C6), // Azul más fuerte para mejor contraste
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// LOADER
// =======================================================

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) =>
            Transform.rotate(angle: _controller.value * 6.28319, child: child),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppTheme.splashArc,
                AppTheme.navSelected,
                isDark ? Colors.transparent : Colors.white,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
