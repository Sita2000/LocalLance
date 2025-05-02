// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logger/logger.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
//   final logger = Logger();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Singleton pattern
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   Future<void> initNotification() async {
//     if (kIsWeb) {
//       logger.d('Web platform detected, skipping notification initialization');
//       return;
//     }

//     try {
//       // Request permission for notifications
//       NotificationSettings settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       logger.d('User granted permission: ${settings.authorizationStatus}');

//       // Get FCM token
//       String? token = await _firebaseMessaging.getToken();
//       logger.d('FCM Token: $token');

//       // Save token to Firestore
//       await _saveTokenToDatabase(token);

//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen((newToken) {
//         logger.d('FCM Token refreshed: $newToken');
//         _saveTokenToDatabase(newToken);
//       });

//       // Initialize local notifications
//       const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//       const iosSettings = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );
//       const initSettings = InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       );
//       await _localNotifications.initialize(initSettings);

//       // Create notification channel for Android
//       await _createNotificationChannel();

//       // Handle foreground messages
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         logger.d('Got a message whilst in the foreground!');
//         logger.d('Message data: ${message.data}');

//         if (message.notification != null) {
//           logger.d('Message also contained a notification: ${message.notification}');
//           _showLocalNotification(message);
//         }
//       });

//       // Handle background messages
//       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//       // Handle notification taps when app is in background or terminated
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         logger.d('Message opened from background: ${message.data}');
//         _handleNotificationTap(message);
//       });

//       // Get initial message when app is opened from terminated state
//       RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//       if (initialMessage != null) {
//         logger.d('App opened from terminated state with message: ${initialMessage.data}');
//         _handleNotificationTap(initialMessage);
//       }

//     } catch (e, stackTrace) {
//       logger.e('Error initializing notifications', error: e, stackTrace: stackTrace);
//     }
//   }

//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     if (notification != null) {
//       await _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             channelDescription: 'This channel is used for important notifications.',
//             importance: Importance.max,
//             priority: Priority.high,
//             icon: android?.smallIcon ?? '@mipmap/ic_launcher',
//             color: Colors.blue,
//             styleInformation: BigTextStyleInformation(
//               notification.body ?? '',
//               htmlFormatBigText: true,
//               contentTitle: notification.title,
//               htmlFormatContentTitle: true,
//             ),
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _saveTokenToDatabase(String? token) async {
//     if (token == null) return;
    
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).update({
//           'fcmToken': token,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//         logger.d('FCM Token saved to Firestore for user: ${user.uid}');
//       }
//     } catch (e) {
//       logger.e('Error saving FCM token to Firestore', error: e);
//     }
//   }

//   void _handleNotificationTap(RemoteMessage message) {
//     // TODO: Implement your navigation logic here based on message data
//     // Example:
//     // if (message.data['type'] == 'chat') {
//     //   Navigator.pushNamed(context, '/chat', arguments: message.data['chatId']);
//     // }
//     logger.d('Notification tapped with data: ${message.data}');
//   }
// }

// // Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
// } 