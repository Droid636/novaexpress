import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  // Consistent method for CommentsSection
  Stream<List<Comment>> getComments(String postId) {
    return commentsForPost(postId);
  }

  final _firestore = FirebaseFirestore.instance;

  Stream<List<Comment>> commentsForPost(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Comment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
    String? profileImageUrl,
  }) async {
    if (content.trim().isEmpty) throw Exception('Comentario vacío');
    final comment = Comment(
      id: '',
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
      profileImageUrl: profileImageUrl,
    );
    await _firestore.collection('comments').add(comment.toMap());
  }

  Future<void> editComment({
    required String commentId,
    required String userId,
    required String newContent,
  }) async {
    final doc = await _firestore.collection('comments').doc(commentId).get();
    if (!doc.exists) throw Exception('Comentario no encontrado');
    final comment = Comment.fromMap(doc.data()!, doc.id);
    if (comment.userId != userId) throw Exception('Sin permiso');
    if (newContent.trim().isEmpty) throw Exception('Comentario vacío');
    await _firestore.collection('comments').doc(commentId).update({
      'content': newContent,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final doc = await _firestore.collection('comments').doc(commentId).get();
    if (!doc.exists) throw Exception('Comentario no encontrado');
    final comment = Comment.fromMap(doc.data()!, doc.id);
    if (comment.userId != userId) throw Exception('Sin permiso');
    await _firestore.collection('comments').doc(commentId).delete();
  }
}
