import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/posts_provider.dart';
import '../components/post_card.dart';
import '../components/news_search_bar.dart';
import '../components/news_bottom_nav_bar.dart';
import '../helpers/app_theme.dart';

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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ---------------- HOME TAB ----------------
  Widget _buildHomeTab() {
    final postsAsync = ref.watch(postsProvider(_lastSearch ?? ''));
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
      child: SingleChildScrollView(
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
              // 🔍 BUSCADOR
              NewsSearchBar(
                initialValue: _lastSearch,
                onSearch: (query) {
                  setState(() => _lastSearch = query);
                },
                onChanged: (query) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    setState(() => _lastSearch = query);
                  });
                },
              ),
              const SizedBox(height: 22),
              // 🖼 IMAGEN HEADER
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/news_header.jpg',
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // 📰 LISTA DE NOTICIAS
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return Container(
                      width: double.infinity,
                      height: 220,
                      alignment: Alignment.center,
                      child: Text(
                        _lastSearch != null && _lastSearch!.isNotEmpty
                            ? 'No se encontraron noticias para "${_lastSearch}".'
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
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(posts[index].id),
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 40)),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: PostCard(post: posts[index]),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: _CustomLoader(),
                ),
                error: (e, _) => Column(
                  children: [
                    Text(
                      e.toString(),
                      style: TextStyle(color: AppTheme.navSelected),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navSelected,
                      ),
                      onPressed: () => setState(() {}),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _buildBookmarksTab() => const Center(child: Text('Favoritos'));
  Widget _buildCategoriesTab() => const Center(child: Text('Categorías'));

  @override
  Widget build(BuildContext context) {
    final body = switch (_selectedIndex) {
      0 => _buildHomeTab(),
      1 => _buildBookmarksTab(),
      2 => _buildCategoriesTab(),
      _ => _buildHomeTab(),
    };

    return Scaffold(
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

// ================= LOADER PERSONALIZADO =================

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
