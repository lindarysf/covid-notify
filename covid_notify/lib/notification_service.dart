import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Android 13 o superior: pedir permiso al usuario en tiempo de ejecución.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'covid_channel',
        'Datos COVID',
        channelDescription: 'Resumen de datos de COVID-19',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    // El id 0 es fijo: cada notificación nueva reemplaza a la anterior.
    await _plugin.show(0, title, body, details);
  }
}