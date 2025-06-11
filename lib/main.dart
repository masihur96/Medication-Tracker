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
      print('Button payload: payload: $payload');
      final medicationId = payload['medication_id'];
      final originalId = payload['original_id'];

      switch (receivedAction.buttonKeyPressed) {

        case 'CONFIRM':
          print('Medication $medicationId confirmed');
          // TODO: Save confirmation to database/local storage
          break;

        case 'SNOOZE':
          print('Medication $medicationId snoozed');

          // Reschedule after 10 minutes
          final newTime = DateTime.now().add(const Duration(minutes: 3));
          final newId = newTime.millisecondsSinceEpoch.remainder(100000);

          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: newId,
              channelKey: 'medication_channel',
              title: 'Snoozed: Medication Reminder',
              body: 'This is a snoozed reminder to take your medication',
              notificationLayout: NotificationLayout.Default,
              payload: {
                'medication_id': medicationId ?? '',
                'original_id': originalId ?? '',
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
                actionType: ActionType.Default,
                color: Colors.orange,
              ),
              NotificationActionButton(
                key: 'SKIP',
                label: 'Skip',
                actionType: ActionType.Default,
                color: Colors.red,
              ),
            ],
          );
          break;

        case 'SKIP':
          print('Medication $medicationId skipped');
          // TODO: Save skip status to local database or analytics
          break;

        default:
        // This was a regular tap (not on a button)
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