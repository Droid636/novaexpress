import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'bookmarks_provider.dart';
import 'providers.dart';

/// Proveedor que obtiene los posts favoritos por sus IDs guardados
import '../services/favorites_cache_service.dart';

final favoritePostsProvider = FutureProvider<List<Post>>((ref) async {
  final bookmarkedIds = ref.watch(bookmarksProvider);
  if (bookmarkedIds.isEmpty) return [];

  final api = ref.watch(apiServiceProvider);
  final List<Post> favorites = [];
  bool anyError = false;
  for (final id in bookmarkedIds) {
    try {
      final response = await api.getPostById(id);
      favorites.add(Post.fromJson(response.data));
    } catch (_) {
      anyError = true;
    }
  }
  // Si hubo error (por ejemplo, sin internet), retorna los favoritos en caché SOLO de los IDs guardados
  if (favorites.isEmpty && anyError) {
    final cached = FavoritesCacheService.getFavorites();
    // Filtra solo los posts cuyo ID está en bookmarkedIds
    return cached.where((post) => bookmarkedIds.contains(post.id)).toList();
  }
  // Si hay algunos favoritos, los retorna (aunque falten algunos)
  return favorites;
});
