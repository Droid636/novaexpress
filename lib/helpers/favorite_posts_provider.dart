import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'bookmarks_provider.dart';
import 'providers.dart';

/// Proveedor que obtiene los posts favoritos por sus IDs guardados
final favoritePostsProvider = FutureProvider<List<Post>>((ref) async {
  final bookmarkedIds = ref.watch(bookmarksProvider);
  if (bookmarkedIds.isEmpty) return [];

  // Traer todos los posts favoritos por ID (uno a uno)
  final api = ref.watch(apiServiceProvider);
  final List<Post> favorites = [];
  for (final id in bookmarkedIds) {
    try {
      final response = await api.getPostById(id);
      favorites.add(Post.fromJson(response.data));
    } catch (_) {
      // Si falla, simplemente no lo agrega
    }
  }
  return favorites;
});
