import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final notificationsPlugin = FlutterLocalNotificationsPlugin();


  bool _isInitialized = false;


  bool get isInitialized => _isInitialized;



  static Future<void> init() async {
    // Timezone setup
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone)); // Change if needed



    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission: true,
          requestSoundPermission: true,
          requestProvisionalPermission: true
        );

    // Initialize notification plugin
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings);
  }


  // Make the phone go ding!
  static Future<void> showNotification(String title, String body) async {
    await notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Important Alerts',
          importance: Importance.high,
        ),
      ),
    );
  }
  static Future<void> schedule(
      DateTime scheduledTime,
      int id,
      {
        String? title,
        String? body
      }
      ) async {
    final now = tz.TZDateTime.now(tz.local);



    var scheduleDate = tz.TZDateTime(

      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.month
    );


    await notificationsPlugin.zonedSchedule(
      id,
      title ?? 'Medication Reminder',
      body ?? 'Time to take your medication',
      scheduleDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),


      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  Future<void> cancelAllNotification()async{
    await notificationsPlugin.cancelAll();
  }


}
