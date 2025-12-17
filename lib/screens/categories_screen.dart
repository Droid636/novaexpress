import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/post.dart';
import '../components/post_card.dart';
import '../helpers/app_theme.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://news.freepi.io/wp-json/wp/v2/'),
  );

  List<Category> _categories = [];
  List<Post> _posts = [];

  int? _selectedCategoryId;
  bool _loadingCategories = true;
  bool _loadingPosts = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // ===============================
  // OBTENER CATEGORÍAS
  // ===============================
  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _error = null;
    });

    try {
      final response = await _dio.get(
        'categories',
        queryParameters: {'per_page': 20},
      );

      final List data = response.data;
      _categories = data
          .map((json) => Category(id: json['id'], name: json['name']))
          .toList();
    } catch (_) {
      _error = 'Error al cargar categorías';
    }

    setState(() {
      _loadingCategories = false;
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
        _fetchPosts(_selectedCategoryId!);
      }
    });
  }

  // ===============================
  // OBTENER POSTS POR CATEGORÍA
  // ===============================
  Future<void> _fetchPosts(int categoryId) async {
    setState(() {
      _loadingPosts = true;
      _error = null;
      _posts.clear();
    });

    final cacheKey = 'cat_posts_$categoryId';

    try {
      final response = await _dio.get(
        'posts',
        queryParameters: {
          'categories': categoryId,
          '_embed': 1,
          'per_page': 10,
        },
      );

      final List data = response.data;

      _posts = data.map((json) => Post.fromJson(json)).toList();

      final prefs = await SharedPreferences.getInstance();
      final cache = _posts.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(cacheKey, cache);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList(cacheKey) ?? [];

      if (cached.isNotEmpty) {
        _posts = cached.map((e) => Post.fromJson(jsonDecode(e))).toList();
        _error = 'Sin conexión. Mostrando noticias guardadas.';
      } else {
        _error = 'No hay conexión y no hay noticias guardadas.';
      }
    }

    setState(() {
      _loadingPosts = false;
    });
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    if (_loadingCategories) {
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
        child: const Center(child: _CustomLoader()),
      );
    }

    if (_error != null && _categories.isEmpty) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                onPressed: _fetchCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navSelected,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // CHIPS
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = cat.id == _selectedCategoryId;

                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategoryId = cat.id);
                      _fetchPosts(cat.id);
                    },
                    selectedColor: AppTheme.navSelected,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.bookmarksTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // LISTA
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _loadingPosts
                    ? const Center(child: _CustomLoader())
                    : _posts.isEmpty
                    ? Center(
                        child: Text(
                          _error ?? 'No hay noticias.',
                          style: TextStyle(color: AppTheme.navUnselected),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 400 + index * 40),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            ),
                            child: PostCard(
                              post: _posts[index],
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
