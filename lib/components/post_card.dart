import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';
import 'post_detail_modal.dart';
import '../helpers/app_theme.dart';

/// ===============================
/// PROVIDER
/// ===============================
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<int>>(
  (ref) => BookmarksNotifier(),
);

/// ===============================
/// NOTIFIER CON CACHE
/// ===============================
class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier() : super({}) {
    _loadBookmarks();
  }

  static const String _storageKey = 'bookmarked_posts';

  bool isBookmarked(Post post) => state.contains(post.id);

  Future<void> addBookmark(Post post) async {
    state = {...state, post.id};
    await _saveBookmarks();
  }

  Future<void> removeBookmark(Post post) async {
    state = state.where((id) => id != post.id).toSet();
    await _saveBookmarks();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      state.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    state = saved.map(int.parse).toSet();
  }
}

/// ===============================
/// POST CARD
/// ===============================
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
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showImage) _buildImage(),
                if (showImage) const SizedBox(width: 16),
                Expanded(child: _buildInfo(dateStr)),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked
                        ? AppTheme.searchIconBg
                        : AppTheme.bookmarksSubtitle.withOpacity(0.4),
                  ),
                  onPressed: () async {
                    final notifier = ref.read(bookmarksProvider.notifier);

                    if (isBookmarked) {
                      await notifier.removeBookmark(post);
                      _snack(context, 'Eliminado de favoritos.');
                    } else {
                      await notifier.addBookmark(post);
                      _snack(context, 'Agregado a favoritos.');
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

  /// ===============================
  /// UI HELPERS
  /// ===============================
  Widget _buildImage() {
    if (post.featuredImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.featuredImage,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.broken_image,
            size: 40,
            color: AppTheme.bookmarksSubtitle,
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.bookmarksBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, size: 36, color: AppTheme.bookmarksSubtitle),
    );
  }

  Widget _buildInfo(String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppTheme.splashBackgroundTop,
            letterSpacing: 0.1,
          ),
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
    );
  }

  void _openDetail(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Detalle Noticia",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: FractionallySizedBox(
            heightFactor: 0.95,
            child: PostDetailModal(post: post),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
