import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  String content;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String? profileImageUrl; // Added profileImageUrl field
  final List<String> likes; // userIds que dieron like
  final List<String> dislikes; // userIds que dieron dislike

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl, // Added profileImageUrl to constructor
    this.likes = const [],
    this.dislikes = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
      profileImageUrl: map['profileImageUrl'] as String?,
      likes: (map['likes'] as List?)?.map((e) => e as String).toList() ?? [],
      dislikes:
          (map['dislikes'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profileImageUrl': profileImageUrl, // Handle profileImageUrl in toMap
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
