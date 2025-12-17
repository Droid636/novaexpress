// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  link: json['link'] as String,
  excerpt: json['excerpt'] as String? ?? '',
  featuredImage: json['featuredImage'] as String? ?? '',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  date: json['date'] as String? ?? '',
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'link': instance.link,
      'excerpt': instance.excerpt,
      'featuredImage': instance.featuredImage,
      'categories': instance.categories,
      'date': instance.date,
    };
