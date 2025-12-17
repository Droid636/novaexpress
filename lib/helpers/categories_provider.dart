import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../helpers/providers.dart';

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api._dio.get('${api.baseUrl}/categories');
  final List data = response.data;
  return data.map((json) => Category.fromJson(json)).toList();
});
