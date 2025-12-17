import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import 'post_detail_modal.dart';
import '../helpers/app_theme.dart';

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<int>>(
  (ref) => BookmarksNotifier(),
);

class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier() : super({});

  bool isBookmarked(Post post) => state.contains(post.id);
  void addBookmark(Post post) => state = {...state, post.id};
  void removeBookmark(Post post) =>
      state = state.where((id) => id != post.id).toSet();
}

class PostCard extends ConsumerWidget {
  final Post post;
  final bool showImage;
  const PostCard({super.key, required this.post, this.showImage = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.tryParse(post.date) ?? DateTime.now());
    final isBookmarked = ref.watch(
      bookmarksProvider.select((set) => set.contains(post.id)),
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.splashBackgroundTop.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppTheme.splashBackgroundBottom.withOpacity(0.10),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierLabel: "Detalle Noticia",
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.3),
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (context, anim1, anim2) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: FractionallySizedBox(
                      heightFactor: 0.95,
                      child: PostDetailModal(post: post),
                    ),
                  ),
                );
              },
              transitionBuilder: (context, anim1, anim2, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim1,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showImage)
                  post.featuredImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.featuredImage,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 40,
                              color: AppTheme.bookmarksSubtitle,
                            ),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.bookmarksBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 36,
                            color: AppTheme.bookmarksSubtitle,
                          ),
                        ),
                if (showImage) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppTheme.splashBackgroundTop,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Publicado: $dateStr',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.navSelected.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked
                        ? AppTheme.searchIconBg
                        : AppTheme.bookmarksSubtitle.withOpacity(0.4),
                  ),
                  onPressed: () {
                    final notifier = ref.read(bookmarksProvider.notifier);
                    if (isBookmarked) {
                      notifier.removeBookmark(post);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Eliminado de favoritos.'),
                        ),
                      );
                    } else {
                      notifier.addBookmark(post);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Agregado a favoritos.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
