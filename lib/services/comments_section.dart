import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/comment.dart';
import 'comment_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
          child: Text(
            'Comentarios',
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : AppTheme.bookmarksTitle,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          height: 2,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.navSelected.withOpacity(0.5)
                : AppTheme.navSelected,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.navBackground.withOpacity(0.7)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: StreamBuilder<List<Comment>>(
              stream: commentService.commentsForPost(widget.postId),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                return Column(
                  children: comments
                      .map(
                        (c) => ListTile(
                          title: Text(
                            c.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.categorySelectedText
                                  : AppTheme.bookmarksTitle,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              c.content,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                          trailing: c.userId == widget.userId
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppTheme.navSelected,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _editingId = c.id;
                                          _controller.text = c.content;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
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
          ),
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.navBackground
                  : AppTheme.categoryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? AppTheme.navSelected.withOpacity(0.4)
                    : AppTheme.navSelected.withOpacity(0.2),
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
          ),
        ),
      ],
    );
  }
}
