import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required int id,
    required String title,
    required String content,
    required String link,
    @Default('') String excerpt,
    @Default('') String featuredImage,
    @Default([]) List<int> categories,
    @Default('') String date,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) {
    // Extraer imagen destacada
    String featuredImage = '';

    if (json.containsKey('_embedded') &&
        json['_embedded'] is Map &&
        json['_embedded']['wp:featuredmedia'] is List &&
        (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
      final media = json['_embedded']['wp:featuredmedia'][0];
      if (media is Map && media['source_url'] is String) {
        featuredImage = media['source_url'];
      }
    } else if (json['jetpack_featured_media_url'] is String) {
      featuredImage = json['jetpack_featured_media_url'];
    }

    return Post(
      id: json['id'] as int,
      title:
          (json['title'] is Map ? json['title']['rendered'] : json['title']) ??
          '',
      content:
          (json['content'] is Map
              ? json['content']['rendered']
              : json['content']) ??
          '',
      link: json['link'] as String? ?? '',
      excerpt: json['excerpt'] is Map
          ? (json['excerpt']['rendered'] ?? '')
          : (json['excerpt'] ?? ''),
      featuredImage: featuredImage,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      date: json['date'] as String? ?? '',
    );
  }
}
