import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/posts_provider.dart';
import '../components/post_card.dart';
import '../components/news_search_bar.dart';
import '../components/news_bottom_nav_bar.dart';
import '../components/theme_menu_button.dart'; // ✅ NUEVO
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
    FavoritesCacheService.init();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ================= HOME TAB =================
  Widget _buildHomeTab(bool isDark) {
    final postsAsync = ref.watch(postsProvider(_lastSearch ?? ''));
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ================= HEADER =================
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'NovaExpress',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppTheme.splashText
                            : AppTheme.bookmarksTitle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.navBackground.withOpacity(0.6)
                            : Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const ThemeMenuButton(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                'Noticias relevantes y actuales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.splashSubtitle
                      : AppTheme.navUnselected,
                ),
              ),
              const SizedBox(height: 22),

              NewsSearchBar(
                initialValue: _lastSearch,
                onSearch: (query) => setState(() => _lastSearch = query),
                onChanged: (query) {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () => setState(() => _lastSearch = query),
                  );
                },
              ),
              const SizedBox(height: 22),

              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/news_header.jpg',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        _lastSearch != null && _lastSearch!.isNotEmpty
                            ? 'No se encontraron noticias para "$_lastSearch".'
                            : 'No hay noticias disponibles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppTheme.navUnselected
                              : AppTheme.bookmarksTitle.withOpacity(0.7),
                        ),
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
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: _CustomLoader(),
                ),
                error: (_, __) => _buildErrorState(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ERROR =================
  Widget _buildErrorState(bool isDark) {
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
              color: isDark ? AppTheme.splashText : AppTheme.bookmarksTitle,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.navSelected,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.invalidate(postsProvider(_lastSearch ?? '')),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================
  Widget _buildBookmarksTab() => const FavoritesScreen();
  Widget _buildCategoriesTab() => const CategoriesScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = switch (_selectedIndex) {
      0 => _buildHomeTab(isDark),
      1 => _buildBookmarksTab(),
      2 => _buildCategoriesTab(),
      _ => _buildHomeTab(isDark),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
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
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.splashBackgroundTop,
                      AppTheme.splashBackgroundBottom,
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.categoryBackground,
                      AppTheme.categoryBackground,
                    ],
                  ),
          ),
          child: body,
        ),
        bottomNavigationBar: NewsBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

// ================= LOADER =================
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
        builder: (_, child) =>
            Transform.rotate(angle: _controller.value * 6.28318, child: child),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppTheme.splashArc,
                AppTheme.navSelected,
                AppTheme.navBackground,
                AppTheme.splashArc.withOpacity(0.2),
                AppTheme.splashArc,
              ],
            ),
          ),
          child: const Center(
            child: CircleAvatar(radius: 11, backgroundColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
