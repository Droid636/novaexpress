import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';
import '../models/post_adapter.dart';

class FavoritesCacheService {
  static const String _boxName = 'favorites_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PostAdapter());
    }
    await Hive.openBox<Post>(_boxName);
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
}
