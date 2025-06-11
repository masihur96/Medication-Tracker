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
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey: 'medication_channel',
          channelName: 'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'medication_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        icon: 'resource://drawable/ic_notification',
      ),
    );
  }

  static Future<void> schedule(
      DateTime scheduledTime,
      int id, {
        String? title,
        String? body,
        String? audioFilePath,
        bool enableVibration = true,
        String? medicationId, // To help identify the medication
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


  }


  // 🔊 Dynamically change sound
  static Future<void> updateChannelSound(String channelKey, String? soundSource) async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: channelKey,
        channelName: 'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: NotificationImportance.High,
        playSound: soundSource != null,
        soundSource: soundSource,
        enableVibration: true,
      ),
    );
  }

  // 🔕 Enable/Disable vibration dynamically
   Future<void> setVibration(String channelKey, bool enabled) async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: channelKey,
        channelName: 'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: NotificationImportance.High,
        enableVibration: enabled,
        playSound: true,
      ),
    );
  }

  // 🔇 Mute all notifications
   Future<void> muteNotifications() async {
    await setVibration('medication_channel', false);
    await updateChannelSound('medication_channel', null);
  }

  // 🔔 Restore sound and vibration
   Future<void> unmuteNotifications({String? customSound}) async {
    await setVibration('medication_channel', true);
    await updateChannelSound('medication_channel', customSound);
  }

  Future<void> setScheduleNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded = decoded.map((e) => Prescription.fromJson(e)).toList();

        for (final prescription in loaded) {
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
    } catch (e, stackTrace) {
      print('Error loading prescriptions: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> cancelAllNotification() async {
    await AwesomeNotifications().cancelAll();
  }

  // 🔔 Notify user if stock is low
  static Future<void> notifyLowStock(String itemName, int currentStock, int threshold) async {
    if (currentStock < threshold) {
      await showNotification(
        'Low Stock Alert',
        'The stock for $itemName is low. Current stock: $currentStock',
      );
    }
  }

  static Future<void> checkLowStock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded = decoded.map((e) => Prescription.fromJson(e)).toList();

        for (final prescription in loaded) {
          for (final med in prescription.medications) {
            if (med.stock <= 0) {
              await showNotification(
                'Low Stock Alert',
                '${med.name} is running low. Current stock: ${med.stock}',
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error checking low stock: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.payload != null) {
      final medicationId = receivedAction.payload!['medication_id'];
      if (medicationId != null) {
        // Navigate to medication details screen
        // You'll need to implement this navigation logic
        print('Notification tapped for medication: $medicationId');
      }
    }
  }
}
