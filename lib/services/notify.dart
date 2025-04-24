// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationHelper {
//   static final FlutterLocalNotificationsPlugin _notifications =
//   FlutterLocalNotificationsPlugin();
//
//   // Set up the ding-dong maker
//   static Future<void> init() async {
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     await _notifications.initialize(
//       const InitializationSettings(
//         android: androidSettings,
//         iOS: DarwinInitializationSettings(),
//       ),
//     );
//   }
//
//   // Make the phone go ding!
//   static Future<void> showNotification(String title, String body) async {
//     await _notifications.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel_id',
//           'Important Alerts',
//           importance: Importance.high,
//         ),
//       ),
//     );
//   }
// }