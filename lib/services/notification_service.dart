import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:med_track/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class NotificationService {
  static Future<void> init() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelKey: 'medication_channel',
          channelName: 'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: NotificationImportance.High,
          playSound: true,
          soundSource: null, // Set per notification
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'medication_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> schedule(
      DateTime scheduledTime,
      int id, {
        String? title,
        String? body,
        String? audioFilePath,
      }) async {
    var scheduleDate = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    String? soundPath;
    if (audioFilePath != null && await File(audioFilePath).exists()) {
      soundPath = Platform.isAndroid ? 'file://$audioFilePath' : audioFilePath;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'medication_channel',
        title: title ?? 'Medication Reminder',
        body: body ?? 'Time to take your medication',
        notificationLayout: NotificationLayout.Default,
        customSound: soundPath,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduleDate.toLocal(),
      ),
    );
  }

  Future<void> setScheduleNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        print("Prescription: $decoded");
        final List<Prescription> loaded =
        decoded.map((e) => Prescription.fromJson(e)).toList();

        for (final prescription in loaded) {
          if (prescription.medications.isNotEmpty) {
            for (final med in prescription.medications) {
              List<DateTime> scheduleList = [];
              for (String dateStr in med.remainderDates) {
                List<String> dateParts = dateStr.split('/');
                int day = int.parse(dateParts[0]);
                int month = int.parse(dateParts[1]);
                int year = int.parse(dateParts[2]);

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

              print("scheduleList: $scheduleList");

              for (DateTime scheduledDateTime in scheduleList) {
                if (scheduledDateTime.isAfter(DateTime.now())) {
                  int notificationId = scheduledDateTime.millisecondsSinceEpoch ~/ 1000;

                  await NotificationService.schedule(
                    scheduledDateTime,
                    notificationId,
                    title: '${med.name} Reminder',
                    body: 'Time to take your medication: ${med.name}\nDosage: ${med.notes}',
                    audioFilePath: med.audioFilePath,
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

  Future<void> cancelAllNotification() async {
    await AwesomeNotifications().cancelAll();
  }
}