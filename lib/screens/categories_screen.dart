import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/categories_providers.dart';
import '../components/post_card.dart';
import '../app_theme.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: categoriesAsync.when(
        loading: () =>
            _screenBackground(isDark, const Center(child: _CustomLoader())),
        error: (e, _) => _screenBackground(isDark, _errorState(ref, isDark)),
        data: (categories) {
          if (categories.isEmpty) {
            return _screenBackground(
              isDark,
              _errorState(ref, isDark, msg: 'No hay categorías.'),
            );
          }

          final selectedId = selectedCategory ?? categories.first.id;
          final postsAsync = ref.watch(postsByCategoryProvider(selectedId));

          return _screenBackground(
            isDark,
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.bookmarksTitle,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final selected = cat.id == selectedId;

                        return ChoiceChip(
                          label: Text(cat.name),
                          selected: selected,
                          onSelected: (_) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                cat.id;
                          },
                          selectedColor: AppTheme.navSelected,
                          backgroundColor: isDark
                              ? AppTheme.navBackground
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : isDark
                                ? Colors.white70
                                : AppTheme.bookmarksTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ================= POSTS =================
                  Expanded(
                    child: postsAsync.when(
                      loading: () => const Center(child: _CustomLoader()),
                      error: (e, _) => Center(
                        child: Text(
                          e.toString().replaceAll('Exception: ', ''),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : AppTheme.navUnselected,
                          ),
                        ),
                      ),
                      data: (posts) => posts.isEmpty
                          ? Center(
                              child: Text(
                                'No hay noticias.',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.navUnselected,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 400 + index * 40,
                                  ),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: PostCard(
                                    post: posts[index],
                                    showImage: true,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _screenBackground(bool isDark, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : AppTheme.categoryBackground,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.splashBackgroundTop,
                  AppTheme.splashBackgroundBottom,
                ],
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _errorState(WidgetRef ref, bool isDark, {String? msg}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.navBackground : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off, size: 48, color: AppTheme.splashArc),
          ),
          const SizedBox(height: 12),
          Text(
            msg ?? 'Sin conexión',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.splashText : AppTheme.bookmarksTitle,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(categoriesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppTheme.navSelected
                  : AppTheme.searchBackground,
              foregroundColor: isDark ? Colors.white : AppTheme.navBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

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
            ),
          ),
        ),
      ),
    );
  }
}
