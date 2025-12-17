import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../helpers/providers.dart';

final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getPosts();
  final List data = response.data;
  return data.map((json) => Post.fromJson(json)).toList();
});
