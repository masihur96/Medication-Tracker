import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/providers/theme_provider.dart';
import 'package:med_track/screens/home_screen.dart';
import 'package:med_track/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
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

  AwesomeNotifications().actionStream.listen((ReceivedAction action) {
    switch (action.buttonKeyPressed) {
      case 'CONFIRM':
      // Handle confirm logic
        print('User confirmed taking the medication');
        break;
      case 'SNOOZE':
      // Reschedule notification after 10 mins (example)
        final now = DateTime.now().add(Duration(minutes: 10));
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: now.millisecondsSinceEpoch.remainder(100000),
            channelKey: 'medication_channel',
            title: 'Snoozed Reminder',
            body: 'Reminder to take your medication',
          ),
          schedule: NotificationCalendar.fromDate(date: tz.TZDateTime.from(now, tz.local)),
        );
        break;
      case 'SKIP':
      // Handle skip logic
        print('User skipped medication');
        break;
    }
  });


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