import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';
import '../models/post_adapter.dart';

class FavoritesCacheService {
  static const String _boxName = 'favorites_cache';
  static const String _idsBoxName = 'favorites_ids_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PostAdapter());
    }
    await Hive.openBox<Post>(_boxName);
    await Hive.openBox<int>(_idsBoxName);
  }

  static Future<void> saveFavorites(List<Post> posts) async {
    final box = Hive.box<Post>(_boxName);
    await box.clear();
    for (var post in posts) {
      await box.put(post.id, post);
    }
  }

  static List<Post> getFavorites() {
    final box = Hive.box<Post>(_boxName);
    return box.values.toList();
  }

  static Future<void> saveFavoriteIds(Set<int> ids) async {
    final box = Hive.box<int>(_idsBoxName);
    await box.clear();
    for (var id in ids) {
      await box.put(id, id);
    }
  }

  static Set<int> getFavoriteIds() {
    final box = Hive.box<int>(_idsBoxName);
    return box.values.toSet();
  }
}
