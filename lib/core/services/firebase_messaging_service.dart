import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Pending notification storage for cold starts (when app was terminated)
  static Map<String, dynamic>? _pendingNotification;

  /// Check and route any pending notification. Called by HomePage once context is ready.
  static void checkAndHandlePendingNotification(BuildContext context) {
    if (_pendingNotification != null) {
      final payload = _pendingNotification!;
      _pendingNotification = null;
      instance._routeNotificationPayload(context, payload);
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Request Permission
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permissions');
        }
      }

      // 2. Local Notifications Setup for Foreground alerts
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final String? payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final Map<String, dynamic> data = jsonDecode(payload);
              handleNotificationClick(data);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing local notification payload: $e');
              }
            }
          }
        },
      );

      // 3. Android High Importance Channel Setup
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'reflections_high_channel',
        'Reflections Reminders',
        description: 'Channel for habit and note reminders',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 4. Foreground notification stream handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && !kIsWeb) {
          final String encodedData = jsonEncode(message.data);

          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: encodedData,
          );
        }
      });

      // 5. App opened from notification handler (Background to Foreground)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('App opened from notification click: ${message.data}');
        }
        handleNotificationClick(message.data);
      });

      // 6. Terminated state opened handler (Cold Start)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('Cold start message received: ${initialMessage.data}');
        }
        handleNotificationClick(initialMessage.data);
      }

      // 7. Get and log FCM Token
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        final token = await _fcm.getToken();
        if (kDebugMode) {
          print('=== Firebase Messaging Token: $token ===');
        }
      }

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging initialization skipped or unsupported on this platform: $e');
      }
    }
  }

  /// Entry point for notification tap handling across all app lifecycle states
  void handleNotificationClick(Map<String, dynamic> data) {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context != null) {
      _routeNotificationPayload(context, data);
    } else {
      // App context not initialized yet (Cold start). Save payload for later execution.
      _pendingNotification = data;
    }
  }

  /// Internal routing helper that dispatches navigation depending on notification type payload
  void _routeNotificationPayload(BuildContext context, Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? url = data['url'];

    if (kDebugMode) {
      print('Routing notification: type=$type, url=$url');
    }

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      switch (type) {
        case 'reminder':
          // ─── Reminder Notification click ───
          noteProvider.changeNavIndex(1); // Tasks Hub
          noteProvider.setSelectedTasksTabIndex(2); // Alarms (ReminderManagerPage)
          break;
        case 'todo':
          // ─── To-Do Alert click ───
          noteProvider.changeNavIndex(1); // Tasks Hub
          noteProvider.setSelectedTasksTabIndex(0); // To-Do Page
          break;
        case 'habit':
          // ─── Habit Alert click ───
          noteProvider.changeNavIndex(1); // Tasks Hub
          noteProvider.setSelectedTasksTabIndex(1); // Habit Tracker Page
          break;
        case 'offer':
        case 'version':
          // ─── Daily Offer Alert / New Version Alert click ───
          if (url != null && url.isNotEmpty) {
            _launchNotificationUrl(url);
          }
          break;
        default:
          // ─── Default / Unknown / General Note updates click ───
          if (url != null && url.isNotEmpty) {
            _launchNotificationUrl(url);
          } else {
            noteProvider.changeNavIndex(0); // Notes Tab
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing notification routing action: $e');
      }
    }
  }

  /// Launches specified URLs externally in the browser or store app
  Future<void> _launchNotificationUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) {
          print('Could not launch URL externally: $urlString');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calling canLaunchUrl/launchUrl: $e');
      }
    }
  }

  Future<void> enableNotifications(bool enabled) async {
    try {
      if (enabled) {
        await _fcm.subscribeToTopic('all_users');
      } else {
        await _fcm.unsubscribeFromTopic('all_users');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing notification subscriptions: $e');
      }
    }
  }
}
