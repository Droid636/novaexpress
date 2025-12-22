import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/post.dart';

class Category {
  final int id;
  final String name;
  Category({required this.id, required this.name});
}

final dioProvider = Provider(
  (ref) => Dio(BaseOptions(baseUrl: 'https://news.freepi.io/wp-json/wp/v2/')),
);

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    'categories',
    queryParameters: {'per_page': 20},
  );
  final List data = response.data;
  return data
      .map((json) => Category(id: json['id'], name: json['name']))
      .toList();
});

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final postsByCategoryProvider = FutureProvider.family<List<Post>, int>((
  ref,
  categoryId,
) async {
  final dio = ref.watch(dioProvider);
  final cacheKey = 'cat_posts_$categoryId';
  try {
    final response = await dio.get(
      'posts',
      queryParameters: {'categories': categoryId, '_embed': 1, 'per_page': 10},
    );
    final List data = response.data;
    final posts = data.map((json) => Post.fromJson(json)).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      cacheKey,
      posts.map((p) => jsonEncode(p.toJson())).toList(),
    );
    return posts;
  } catch (_) {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(cacheKey) ?? [];
    if (cached.isNotEmpty) {
      return cached.map((e) => Post.fromJson(jsonDecode(e))).toList();
    } else {
      throw Exception('No hay conexión y no hay noticias guardadas.');
    }
  }
});
