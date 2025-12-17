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

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
