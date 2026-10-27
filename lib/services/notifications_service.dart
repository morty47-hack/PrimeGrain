import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService {
  NotificationsService._();

  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'primegrain_welcome';

  Future<void> init() async {
    if (kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios, linux: linux),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'PrimeGrain messages',
      description: 'Welcome and account notifications',
      importance: Importance.high,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);
  }

  Future<void> maybeShowWelcomeForEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'welcome_shown_$normalized';
    final alreadyShown = prefs.getBool(key) ?? false;
    if (alreadyShown) return;

    await prefs.setBool(key, true);

    const message =
        'WELCOME TO PRIMEGRAIN -A TRADING PLATFORM FOR BUYING FOODSTUFFS IN SMALL AND BULK QUANTITIES AS PER YOUR SATISFACTION.WE ARE HERE TO SERVE YOU .';

    if (kIsWeb) return;

    await _plugin.show(
      1001,
      'PrimeGrain',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'PrimeGrain messages',
          channelDescription: 'Welcome and account notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      ),
    );
  }
}

