import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:med_track/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    var scheduleDate = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
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

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  Future<void> cancelAllNotification()async{
    await notificationsPlugin.cancelAll();
  }


  Future<void> setScheduleNotification() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded =
        decoded.map((e) => Prescription.fromJson(e)).toList();
        // Collect today's medications and schedule notifications
        for (final prescription in loaded) {
          if(prescription.medications.isNotEmpty){
            for (final med in prescription.medications) {
              // Create a list to store all scheduled DateTimes
              List<DateTime> scheduleList = [];
              // For each date, combine with all times
              for (String dateStr in med.remainderDates) {
                // Parse the date string (DD/MM/YYYY format)
                List<String> dateParts = dateStr.split('/');
                int day = int.parse(dateParts[0]);
                int month = int.parse(dateParts[1]);
                int year = int.parse(dateParts[2]);

                // For each time, create a DateTime object
                for (TimeOfDay time in med.reminderTimes) {
                  DateTime scheduledDateTime = DateTime(
                    year,
                    month,
                    day,
                    time.hour,
                    time.minute,
                  );
                  scheduleList.add(scheduledDateTime);
                }
              }
              // Now scheduleList contains all date-time combinations
              log("Scheduled times: $scheduleList");
              // await NotificationScheduler.scheduleAll(scheduleList);
              for (DateTime scheduledDateTime in scheduleList) {
                // Check if the scheduled time is in the future
                if (scheduledDateTime.isAfter(DateTime.now())) {
                  // Generate a unique ID for each notification
                  // Using milliseconds since epoch to ensure uniqueness
                  int notificationId = scheduledDateTime.millisecondsSinceEpoch ~/ 1000;

                  await NotificationService.schedule(
                    scheduledDateTime,
                    notificationId,
                    title: '${med.name} Reminder', // Add medication name
                    body: 'Time to take your medication: ${med.name}\nDosage: ${med.notes}', // Add relevant details
                  );
                }
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error loading prescriptions: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
