import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../helpers/providers.dart';

final postsProvider = FutureProvider.autoDispose.family<List<Post>, String>((
  ref,
  search,
) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getPosts(
    search: search.isNotEmpty ? search : null,
  );
  final List data = response.data;
  return data.map((json) => Post.fromJson(json)).toList();
});
