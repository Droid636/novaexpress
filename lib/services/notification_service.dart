import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  Future<void> requestPermissionIfNeeded() async {
    await _messaging.requestPermission();
  }

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static const String _prefsKey = 'subscribed_topics';

  Future<List<String>> getSubscribedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> subscribeToTopic(String topic) async {
    final topics = await getSubscribedTopics();
    if (!topics.contains(topic)) {
      print('[NotificationService] Suscribiéndose al tópico: $topic');
      await _messaging.subscribeToTopic(topic);
      print(
        '[NotificationService] Llamada a FirebaseMessaging.subscribeToTopic($topic) realizada',
      );
      topics.add(topic);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, topics);
      print('[NotificationService] Tópicos suscritos actualizados: $topics');
    } else {
      print('[NotificationService] Ya estaba suscrito al tópico: $topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final topics = await getSubscribedTopics();
    if (topics.contains(topic)) {
      print('[NotificationService] Desuscribiéndose del tópico: $topic');
      await _messaging.unsubscribeFromTopic(topic);
      print(
        '[NotificationService] Llamada a FirebaseMessaging.unsubscribeFromTopic($topic) realizada',
      );
      topics.remove(topic);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, topics);
      print('[NotificationService] Tópicos suscritos actualizados: $topics');
    } else {
      print('[NotificationService] No estaba suscrito al tópico: $topic');
    }
  }

  Future<void> setTopics(List<String> topics) async {
    final current = await getSubscribedTopics();
    for (final t in current) {
      if (!topics.contains(t)) {
        print(
          '[NotificationService] Desuscribiéndose del tópico (setTopics): $t',
        );
        await _messaging.unsubscribeFromTopic(t);
      }
    }
    for (final t in topics) {
      if (!current.contains(t)) {
        print('[NotificationService] Suscribiéndose al tópico (setTopics): $t');
        await _messaging.subscribeToTopic(t);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, topics);
    print(
      '[NotificationService] Tópicos suscritos actualizados (setTopics): $topics',
    );
  }
}
