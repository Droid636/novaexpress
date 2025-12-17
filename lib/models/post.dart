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
      featuredImage: json['jetpack_featured_media_url'] as String? ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      date: json['date'] as String? ?? '',
    );
  }
}
