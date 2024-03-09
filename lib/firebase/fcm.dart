import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterfire_playground/main.dart';

import '../pages/notification/notification.dart';

class FCMApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getDeviceToken() async => await _firebaseMessaging.getToken();

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
      NotificationView.route,
      arguments: message,
    );
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const ios = DarwinInitializationSettings();
    // const macos = DarwinInitializationSettings();
    // const linux = LinuxInitializationSettings(defaultActionName: 'flutterfire_playground');
    // const settings = InitializationSettings(android: android, iOS: ios, linux: linux, macOS: macos);
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      handleMessage(message);
    });

    final androidPlatform =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // final iosPlatform = _localNotifications.resolvePlatformSpecificImplementation<
    //     IOSFlutterLocalNotificationsPlugin>();

    // final macosPlatform = _localNotifications.resolvePlatformSpecificImplementation<
    //     MacOSFlutterLocalNotificationsPlugin>();

    // final linuxPlatform = _localNotifications.resolvePlatformSpecificImplementation<
    //     LinuxFlutterLocalNotificationsPlugin>();

    await androidPlatform?.createNotificationChannel(_androidChannel);
    // await iosPlatform?.requestPermissions();
    // await macosPlatform?.requestPermissions();
    // await linuxPlatform?.getActiveNotifications();
  }

  Future initPushNotification() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    final token = await getDeviceToken();
    debugPrint('>> Device Token: $token');
    initPushNotification();
    initLocalNotifications();
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('>> Title: ${message.notification?.title}');
  debugPrint('>> Body: ${message.notification?.body}');
  debugPrint('>> Data: ${message.data}');
}
