import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/categories_providers.dart';
import '../services/notification_service.dart';
import '../app_theme.dart';

class NotificationTopicsScreen extends ConsumerStatefulWidget {
  const NotificationTopicsScreen({super.key});

  @override
  ConsumerState<NotificationTopicsScreen> createState() =>
      _NotificationTopicsScreenState();
}

class _NotificationTopicsScreenState
    extends ConsumerState<NotificationTopicsScreen> {
  late Future<List<String>> _subscribedTopicsFuture;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _subscribedTopicsFuture = NotificationService().getSubscribedTopics();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await NotificationService().requestPermissionIfNeeded();
    } catch (e) {
      // Manejar error de permisos si es necesario
    }
  }

  void _refresh() {
    setState(() {
      _subscribedTopicsFuture = NotificationService().getSubscribedTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones por categoría'),
        backgroundColor: isDark ? AppTheme.navBackground : AppTheme.navSelected,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: isDark
          ? AppTheme.navBackground
          : AppTheme.categoryBackground,
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          return FutureBuilder<List<String>>(
            future: _subscribedTopicsFuture,
            builder: (context, snapshot) {
              // Mientras carga el Future de tópicos, mostramos un indicador local o lista vacía
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final subscribed = snapshot.data ?? [];

              return SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  color: isDark
                      ? AppTheme.navBackground
                      : AppTheme.bookmarksCard,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activa o desactiva las notificaciones para cada categoría:',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppTheme.bookmarksTitle,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...categories.map((cat) {
                          final topic = 'cat_${cat.id}';
                          final isSubscribed = subscribed.contains(topic);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSubscribed
                                  ? (isDark
                                        ? AppTheme.navSelected.withOpacity(0.15)
                                        : AppTheme.categorySelectedGradientStart
                                              .withOpacity(0.12))
                                  : (isDark
                                        ? AppTheme.navBackground
                                        : AppTheme.categoryChipBackground),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSubscribed
                                    ? (isDark
                                          ? AppTheme.navSelected
                                          : AppTheme
                                                .categorySelectedGradientStart)
                                    : (isDark
                                          ? AppTheme.navUnselected
                                          : AppTheme.categoryChipBorder),
                                width: 1.5,
                              ),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isSubscribed
                                      ? (isDark
                                            ? AppTheme.categorySelectedText
                                            : AppTheme
                                                  .categorySelectedGradientStart)
                                      : (isDark
                                            ? AppTheme.navUnselected
                                            : AppTheme.categoryChipText),
                                ),
                              ),
                              value: isSubscribed,
                              activeColor: isDark
                                  ? AppTheme.navSelected
                                  : AppTheme.categorySelectedGradientStart,
                              onChanged: (val) async {
                                if (val) {
                                  await NotificationService().subscribeToTopic(
                                    topic,
                                  );
                                  // Mostrar notificación local
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Suscrito a notificaciones de ${cat.name}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  await NotificationService()
                                      .unsubscribeFromTopic(topic);
                                  // Mostrar notificación local
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Notificaciones de ${cat.name} desactivadas',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                                _refresh();
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
