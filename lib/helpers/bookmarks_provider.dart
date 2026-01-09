import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import '../services/favorites_cache_service.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<int>>((
  ref,
) {
  final user = ref.watch(authUserProvider).asData?.value;
  return BookmarksNotifier(user);
});

class BookmarksNotifier extends StateNotifier<Set<int>> {
  final User? user;

  BookmarksNotifier(this.user) : super({}) {
    _loadBookmarks();
  }

  String get _storageKey => 'bookmarked_posts_${user?.uid ?? "guest"}';

  bool isBookmarked(Post post) => state.contains(post.id);

  Future<void> addBookmark(Post post) async {
    state = {...state, post.id};
    await _saveBookmarks();
    await _saveToFirestore();

    final currentFavorites = FavoritesCacheService.getFavorites();
    final updatedFavorites = {...currentFavorites, post};
    await FavoritesCacheService.saveFavorites(updatedFavorites.toList());
  }

  Future<void> removeBookmark(Post post) async {
    state = state.where((id) => id != post.id).toSet();
    await _saveBookmarks();
    await _saveToFirestore();

    final currentFavorites = FavoritesCacheService.getFavorites();
    final updatedFavorites = currentFavorites
        .where((p) => p.id != post.id)
        .toList();
    await FavoritesCacheService.saveFavorites(updatedFavorites);
  }

  Future<void> logout() async {
    // Llama esto al cerrar sesión
    await FavoritesCacheService.clearCache();
    state = {};
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      state.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _loadBookmarks() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();
      if (data != null && data['favorites'] is List) {
        final favs = (data['favorites'] as List)
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toSet();

        state = favs;
        await _saveBookmarks();
        // Aquí deberías cargar los posts favoritos desde la API y guardarlos en Hive
        try {
          final posts = <Post>[];
          for (final id in favs) {}
        } catch (_) {}
        return;
      }
    }

    // 📦 Fallback local
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    state = saved.map(int.parse).toSet();
  }

  Future<void> _saveToFirestore() async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'favorites': state.map((e) => e.toString()).toList(),
    }, SetOptions(merge: true));
  }
}
