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
      await _messaging.subscribeToTopic(topic);
      topics.add(topic);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, topics);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final topics = await getSubscribedTopics();
    if (topics.contains(topic)) {
      await _messaging.unsubscribeFromTopic(topic);
      topics.remove(topic);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, topics);
    }
  }

  Future<void> setTopics(List<String> topics) async {
    final current = await getSubscribedTopics();
    for (final t in current) {
      if (!topics.contains(t)) {
        await _messaging.unsubscribeFromTopic(t);
      }
    }
    for (final t in topics) {
      if (!current.contains(t)) {
        await _messaging.subscribeToTopic(t);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, topics);
  }
}
