import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/bookmarks_provider.dart';
import '../models/post.dart';
import 'post_detail_modal.dart';
import '../app_theme.dart';

/// ===============================
/// POST CARD
/// ===============================
class PostCard extends ConsumerWidget {
  final Post post;
  final bool showImage;

  const PostCard({super.key, required this.post, this.showImage = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🔒 Detectar modo invitado
    final isGuest = FirebaseAuth.instance.currentUser == null;

    final dateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.tryParse(post.date) ?? DateTime.now());

    final isBookmarked = ref.watch(
      bookmarksProvider.select((set) => set.contains(post.id)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navBackground : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : AppTheme.splashBackgroundTop.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppTheme.splashBackgroundBottom.withOpacity(0.10),
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
                if (showImage) _buildImage(isDark),
                if (showImage) const SizedBox(width: 16),
                Expanded(child: _buildInfo(dateStr, isDark)),

                // ⭐ Botón de favoritos SOLO si NO es invitado
                if (!isGuest)
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? AppTheme.navSelected
                          : isDark
                          ? Colors.white54
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

  Widget _buildImage(bool isDark) {
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
            color: isDark ? Colors.white54 : AppTheme.bookmarksSubtitle,
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppTheme.bookmarksBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        size: 36,
        color: isDark ? Colors.white54 : AppTheme.bookmarksSubtitle,
      ),
    );
  }

  Widget _buildInfo(String dateStr, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? Colors.white : AppTheme.splashBackgroundTop,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Publicado: $dateStr',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppTheme.splashSubtitle
                : AppTheme.navSelected.withOpacity(0.85),
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
