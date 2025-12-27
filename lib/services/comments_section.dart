import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Widget build(BuildContext context) {
    final commentService = ref.watch(commentServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<Comment>>(
          stream: commentService.commentsForPost(widget.postId),
          builder: (context, snapshot) {
            final comments = snapshot.data ?? [];
            return Column(
              children: comments
                  .map(
                    (c) => ListTile(
                      title: Text(c.userName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.content),
                          Text(
                            'userId: ${c.userId}',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: c.userId == widget.userId
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _editingId = c.id;
                                      _controller.text = c.content;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
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
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _editingId == null
                      ? 'Agregar comentario...'
                      : 'Editar comentario...',
                ),
              ),
            ),
            IconButton(
              icon: Icon(_editingId == null ? Icons.send : Icons.check),
              onPressed: () async {
                try {
                  if (_editingId == null) {
                    await commentService.addComment(
                      postId: widget.postId,
                      userId: widget.userId,
                      userName: widget.userName,
                      content: _controller.text,
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
      ],
    );
  }
}
