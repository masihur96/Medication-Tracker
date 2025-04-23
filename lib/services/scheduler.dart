// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'notify.dart';
//
// class NotificationScheduler {
//
//   static final _notifications = FlutterLocalNotificationsPlugin();
//
//
//   // Set up the world clock
//   static void setup() {
//     tz.initializeTimeZones();
//   }
//
//
//
//   // Set alarms for all the times
//   static Future<void> scheduleAll(List<DateTime> dateTimes) async {
//     for (DateTime dateStr in dateTimes) {
//       DateTime date = dateStr;
//       tz.TZDateTime scheduledTime = tz.TZDateTime.from(date, tz.local);
//
//       _notifications.zonedSchedule(
//         dateTimes.indexOf(dateStr),
//         "Time's up!",
//         "It's ${date.hour}:${date.minute} now!",
//         scheduledTime,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'channel_id',
//             'Important Alerts',
//             importance: Importance.high,
//           ),
//         ),
//          androidScheduleMode: AndroidScheduleMode.alarmClock,
//       );
//     }
//   }
// }