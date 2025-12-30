import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../models/comment.dart';
import 'comment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final commentServiceProvider = Provider<CommentService>(
  (ref) => CommentService(),
);

class CommentsSection extends ConsumerStatefulWidget {
  final String postId;
  final String userId;
  final String userName;

  const CommentsSection({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _controller = TextEditingController();
  String? _editingId;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentService = ref.watch(commentServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0, top: 16.0),
          child: Text(
            'Comentarios',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),

        // Lista de comentarios
        StreamBuilder<List<Comment>>(
          stream: commentService.getComments(widget.postId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No hay comentarios aún.'),
              );
            }

            final comments = snapshot.data!;
            return Column(
              children: comments
                  .map(
                    (c) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          c.profileImageUrl != null &&
                              c.profileImageUrl!.isNotEmpty
                          ? CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(c.profileImageUrl!),
                              backgroundColor: Colors.grey[300],
                            )
                          : CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.navSelected,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                      title: Text(
                        c.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.categorySelectedText
                              : AppTheme.bookmarksTitle,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.content,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final userId = widget.userId;
                                  if (c.likes.contains(userId)) {
                                    await commentService.removeLikeDislike(
                                      commentId: c.id,
                                      userId: userId,
                                    );
                                  } else {
                                    await commentService.likeComment(
                                      commentId: c.id,
                                      userId: userId,
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up,
                                      size: 18,
                                      color: c.likes.contains(widget.userId)
                                          ? AppTheme.navSelected
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${c.likes.length}',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () async {
                                  final userId = widget.userId;
                                  if (c.dislikes.contains(userId)) {
                                    await commentService.removeLikeDislike(
                                      commentId: c.id,
                                      userId: userId,
                                    );
                                  } else {
                                    await commentService.dislikeComment(
                                      commentId: c.id,
                                      userId: userId,
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_down,
                                      size: 18,
                                      color: c.dislikes.contains(widget.userId)
                                          ? Colors.redAccent
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${c.dislikes.length}',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: c.userId == widget.userId
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppTheme.navSelected,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _editingId = c.id;
                                      _controller.text = c.content;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await commentService.deleteComment(
                                        commentId: c.id,
                                        userId: widget.userId,
                                      );
                                    } catch (e) {
                                      setState(() => _error = e.toString());
                                    }
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  )
                  .toList(),
            );
          },
        ),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // Input de texto
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.navBackground
                  : AppTheme.categoryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.navSelected.withOpacity(isDark ? 0.4 : 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: _editingId == null
                          ? 'Agregar comentario...'
                          : 'Editar comentario...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _editingId == null ? Icons.send : Icons.check,
                    color: AppTheme.navSelected,
                  ),
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;
                    try {
                      if (_editingId == null) {
                        // Get user profile image from Firestore
                        String? profileImageUrl;
                        try {
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .get();
                          if (userDoc.exists) {
                            final data = userDoc.data();
                            if (data != null &&
                                data['profileImage'] != null &&
                                (data['profileImage'] as String).isNotEmpty) {
                              profileImageUrl = data['profileImage'] as String;
                            }
                          }
                        } catch (_) {}
                        await commentService.addComment(
                          postId: widget.postId,
                          userId: widget.userId,
                          userName: widget.userName,
                          content: _controller.text,
                          profileImageUrl: profileImageUrl,
                        );
                      } else {
                        await commentService.editComment(
                          commentId: _editingId!,
                          userId: widget.userId,
                          newContent: _controller.text,
                        );
                      }
                      setState(() {
                        _controller.clear();
                        _editingId = null;
                        _error = null;
                      });
                    } catch (e) {
                      setState(() => _error = e.toString());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
