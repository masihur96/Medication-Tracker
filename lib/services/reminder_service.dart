import 'package:flutter_tts/flutter_tts.dart';
import 'package:med_track/models/medication.dart';

class ReminderService {
  final FlutterTts tts = FlutterTts();

  // Future<void> scheduleReminders(Medication med) async {
  //   for (var time in med.timesPerDay) {
  //     // Schedule notification for each time
  //     // This is simplified - you'll need to use flutter_local_notifications package
  //     await tts.speak("Time to take your ${med.name}");
  //   }
  // }
}