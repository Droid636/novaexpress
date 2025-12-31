import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/categories_providers.dart';
import '../services/notification_service.dart';

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
      // Puedes mostrar un mensaje si lo deseas
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
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones por categoría')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          return FutureBuilder<List<String>>(
            future: _subscribedTopicsFuture,
            builder: (context, snapshot) {
              final subscribed = snapshot.data ?? [];
              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Activa o desactiva las notificaciones para cada categoría:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...categories.map((cat) {
                    final topic = 'cat_${cat.id}';
                    final isSubscribed = subscribed.contains(topic);
                    return SwitchListTile(
                      title: Text(cat.name),
                      value: isSubscribed,
                      onChanged: (val) async {
                        if (val) {
                          await NotificationService().subscribeToTopic(topic);
                        } else {
                          await NotificationService().unsubscribeFromTopic(
                            topic,
                          );
                        }
                        _refresh();
                      },
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
