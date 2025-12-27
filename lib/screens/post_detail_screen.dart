import 'package:flutter/material.dart';
import '../models/post.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/comments_section.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime? date;
    try {
      date = DateTime.tryParse(post.date);
    } catch (_) {
      date = null;
    }

    return Container(
      color: isDark ? AppTheme.navBackground : AppTheme.categoryBackground,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGEN =================
            if (post.featuredImage.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post.featuredImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  ),

                  // ❌ BOTÓN CERRAR (CLARO / OSCURO)
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Material(
                      color: isDark ? AppTheme.navBackground : Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 26,
                            color: isDark ? Colors.white : AppTheme.navSelected,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (post.featuredImage.isNotEmpty) const SizedBox(height: 18),

            // ================= TÍTULO =================
            Text(
              post.title,
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : AppTheme.bookmarksTitle,
              ),
            ),

            const SizedBox(height: 10),

            // ================= SEPARADOR =================
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.navSelected,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 18),

            // ================= CONTENIDO HTML =================
            HtmlWidget(
              post.content,
              textStyle: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17,
                height: 1.6,
                color: isDark ? Colors.white70 : const Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 18),

            // ================= FECHA =================
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                date != null
                    ? 'Publicado: ${date.day}/${date.month}/${date.year}'
                    : '',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : AppTheme.navUnselected,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ================= COMENTARIOS =================
            Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inicia sesión para comentar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/login'),
                          child: Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  );
                }
                return CommentsSection(
                  postId: post.id.toString(),
                  userId: user.uid,
                  userName: user.displayName ?? user.email ?? '',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
