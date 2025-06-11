import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/providers/theme_provider.dart';
import 'package:med_track/screens/home_screen.dart';
import 'package:med_track/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:med_track/providers/language_provider.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:med_track/screens/lock_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  
  // Initialize providers
  final medicationProvider = MedicationProvider();
  await medicationProvider.initialize();
  final themeProvider = ThemeProvider();
  final languageProvider = LanguageProvider();

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (ReceivedAction receivedAction) async {
      final payload = receivedAction.payload ?? {};
      final medicationId = payload['medication_id'];
      final originalId = payload['original_id'];
      final missedCount = int.tryParse(payload['missed_count'] ?? '0') ?? 0;
      final nextDoseTime = payload['next_dose_time'];

      switch (receivedAction.buttonKeyPressed) {
        case 'CONFIRM':
          print('Medication $medicationId confirmed');
          // Reset missed count when confirmed
          await _updateMedicationStatus(medicationId, true);
          break;

        case 'SNOOZE':
          print('Medication $medicationId snoozed');
          
          // Calculate smart snooze duration based on missed count
          final snoozeDuration = _calculateSmartSnoozeDuration(missedCount);
          final newTime = DateTime.now().add(snoozeDuration);
          final newId = newTime.millisecondsSinceEpoch.remainder(100000);

          // Increment missed count
          final newMissedCount = missedCount + 1;

          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: newId,
              channelKey: 'medication_channel',
              title: 'Snoozed: Medication Reminder',
              body: 'This is a snoozed reminder to take your medication (Missed: $newMissedCount times)',
              notificationLayout: NotificationLayout.Default,
              payload: {
                'medication_id': medicationId ?? '',
                'original_id': originalId ?? '',
                'missed_count': newMissedCount.toString(),
                'next_dose_time': nextDoseTime,
              },
            ),
            schedule: NotificationCalendar.fromDate(date: tz.TZDateTime.from(newTime, tz.local)),
            actionButtons: [
              NotificationActionButton(
                key: 'CONFIRM',
                label: 'Confirm',
                actionType: ActionType.Default,
                color: Colors.green,
              ),
              NotificationActionButton(
                key: 'SNOOZE',
                label: 'Snooze',
                actionType: ActionType.KeepOnTop,
                color: Colors.orange,
              ),
              NotificationActionButton(
                key: 'SKIP',
                label: 'Skip',
                actionType: ActionType.KeepOnTop,
                color: Colors.red,
              ),
            ],
          );

          // Update medication status in database
          await _updateMedicationStatus(medicationId, false, newMissedCount);
          break;

        case 'SKIP':
          print('Medication $medicationId skipped');
          await _updateMedicationStatus(medicationId, false, missedCount + 1);
          
          // Schedule next dose if available
          if (nextDoseTime != null) {
            final nextDose = DateTime.parse(nextDoseTime);
            if (nextDose.isAfter(DateTime.now())) {
              await _scheduleNextDose(medicationId, nextDose);
            }
          }
          break;

        default:
          if (medicationId != null && medicationId.isNotEmpty) {
            print('Notification tapped for medication: $medicationId');
            // TODO: Navigate to medication detail screen
          }
          break;
      }
    },
  );



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: medicationProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => languageProvider),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'MedTrack',
          theme: themeProvider.getTheme(),
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'), // English
            Locale('bn'), // Bengali
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: FutureBuilder<bool>(
            future: _checkBiometricLock(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }


              
              final bool isBiometricLockEnabled = snapshot.data ?? false;

              return isBiometricLockEnabled ? const LockScreen() : const HomeScreen();
            },
          ),
        );
      },
    );
  }

  Future<bool> _checkBiometricLock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_lock') ?? false;
  }
}

// Helper function to calculate smart snooze duration
Duration _calculateSmartSnoozeDuration(int missedCount) {
  switch (missedCount) {
    case 0:
      return const Duration(minutes: 15); // First snooze: 15 minutes
    case 1:
      return const Duration(minutes: 30); // Second snooze: 30 minutes
    case 2:
      return const Duration(hours: 1); // Third snooze: 1 hour
    default:
      return const Duration(hours: 2); // Subsequent snoozes: 2 hours
  }
}

// Helper function to update medication status
Future<void> _updateMedicationStatus(String? medicationId, bool isConfirmed, [int missedCount = 0]) async {
  if (medicationId == null) return;
  
  // TODO: Implement this method to update your medication status in the database
  // This should update the missed count and confirmation status
  // Example implementation:
  // await medicationProvider.updateMedicationStatus(
  //   medicationId,
  //   isConfirmed: isConfirmed,
  //   missedCount: missedCount,
  // );
}

// Helper function to schedule next dose
Future<void> _scheduleNextDose(String? medicationId, DateTime nextDoseTime) async {
  if (medicationId == null) return;

  final newId = nextDoseTime.millisecondsSinceEpoch.remainder(100000);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: newId,
      channelKey: 'medication_channel',
      title: 'Next Medication Reminder',
      body: 'Time for your next scheduled dose',
      notificationLayout: NotificationLayout.Default,
      payload: {
        'medication_id': medicationId,
        'missed_count': '0',
      },
    ),
    schedule: NotificationCalendar.fromDate(date: tz.TZDateTime.from(nextDoseTime, tz.local)),
    actionButtons: [
      NotificationActionButton(
        key: 'CONFIRM',
        label: 'Confirm',
        actionType: ActionType.Default,
        color: Colors.green,
      ),
      NotificationActionButton(
        key: 'SNOOZE',
        label: 'Snooze',
        actionType: ActionType.KeepOnTop,
        color: Colors.orange,
      ),
      NotificationActionButton(
        key: 'SKIP',
        label: 'Skip',
        actionType: ActionType.KeepOnTop,
        color: Colors.red,
      ),
    ],
  );
}