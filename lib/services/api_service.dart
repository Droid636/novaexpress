import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://news.freepi.io/wp-json/wp/v2';

  Future<Response> getPosts({int page = 1, int perPage = 10, String? search, int? category}) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null) 'search': search,
      if (category != null) 'categories': category,
    };
    return await _dio.get('$baseUrl/posts', queryParameters: params);
  }
}
