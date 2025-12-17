import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/posts_provider.dart';
import '../components/post_card.dart';
import '../components/news_search_bar.dart';
import '../components/news_bottom_nav_bar.dart';
import '../helpers/app_theme.dart';
import 'favorites_screen.dart';
import 'categories_screen.dart';
import '../services/favorites_cache_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _debounce;
  String? _lastSearch;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initFavoritesCache();
  }

  Future<void> _initFavoritesCache() async {
    await FavoritesCacheService.init();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ================= HOME TAB (CON EL DISEÑO DEL ANTIGUO) =================
  Widget _buildHomeTab() {
    final postsAsync = ref.watch(postsProvider(_lastSearch ?? ''));
    final bookmarkedIds = ref.watch(bookmarksProvider);

    postsAsync.whenData((posts) {
      final bookmarkedPosts = posts
          .where((post) => bookmarkedIds.contains(post.id))
          .toList();
      FavoritesCacheService.saveFavorites(bookmarkedPosts);
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // TÍTULO
            Text(
              'NovaExpress',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppTheme.splashText,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // SUBTÍTULO
            Text(
              'Noticias relevantes y actuales',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.splashLogoGlow,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),

            // BUSCADOR
            NewsSearchBar(
              initialValue: _lastSearch,
              onSearch: (query) {
                setState(() => _lastSearch = query);
              },
              onChanged: (query) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 400),
                  () => setState(() => _lastSearch = query),
                );
              },
            ),
            const SizedBox(height: 22),

            // IMAGEN HEADER
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/news_header.jpg',
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // LISTA DE NOTICIAS
            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      _lastSearch != null && _lastSearch!.isNotEmpty
                          ? 'No se encontraron noticias para "$_lastSearch".'
                          : 'No hay noticias disponibles.',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppTheme.navUnselected,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(post.id),
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + index * 40),
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
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 32),
                child: _CustomLoader(), // Cargador antiguo con diseño pro
              ),
              error: (_, __) => _buildErrorState(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= OTROS TABS =================
  Widget _buildBookmarksTab() => const FavoritesScreen();
  Widget _buildCategoriesTab() => const CategoriesScreen();

  // ================= ERROR STATE =================
  bool _isRetrying = false;
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.wifi_off, size: 48, color: AppTheme.splashArc),
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
                    ref.invalidate(postsProvider(_lastSearch ?? ''));
                    setState(() => _isRetrying = false);
                  },
            icon: _isRetrying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isRetrying ? 'Cargando...' : 'Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_selectedIndex) {
      0 => _buildHomeTab(),
      1 => _buildBookmarksTab(),
      2 => _buildCategoriesTab(),
      _ => _buildHomeTab(),
    };

    return Scaffold(
      // Se aplica el gradiente a todo el Scaffold como en el diseño antiguo
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: body,
      ),
      bottomNavigationBar: NewsBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ================= EL LOADER PRO DEL DISEÑO ANTIGUO =================

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
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 6.28319,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppTheme.splashArc,
                AppTheme.navSelected,
                AppTheme.splashBackgroundTop,
                AppTheme.splashArc.withOpacity(0.2),
                AppTheme.splashArc,
              ],
              stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.splashArc.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
