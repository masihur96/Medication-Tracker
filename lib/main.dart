import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:med_track/providers/language_provider.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/providers/theme_provider.dart';
import 'package:med_track/screens/home_screen.dart';
import 'package:med_track/screens/lock_screen.dart';
import 'package:med_track/services/notification_service.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    print('🚀 Starting app initialization...');
    try {
      await NotificationService.init();
      print('✅ NotificationService initialized');
    } catch (e) {
      print('⚠️ NotificationService initialization failed: $e');
    }

    // Initialize providers with error handling
    final medicationProvider = MedicationProvider();
    try {
      await medicationProvider.initialize();
      print('✅ MedicationProvider initialized');
    } catch (e) {
      print('⚠️ MedicationProvider initialization failed: $e');
    }

    final themeProvider = ThemeProvider();
    final languageProvider = LanguageProvider();
    print('✅ All providers created');

    // Set up notification listeners with error handling
    try {
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: (ReceivedAction receivedAction) async {
          try {
            final payload = receivedAction.payload ?? {};
            final medicationId = payload['medication_id'];
            final originalId = payload['original_id'];
            final missedCount =
                int.tryParse(payload['missed_count'] ?? '0') ?? 0;
            final nextDoseTime = payload['next_dose_time'];

            switch (receivedAction.buttonKeyPressed) {
              case 'CONFIRM':
                print('Medication $medicationId confirmed');
                await _updateMedicationStatus(medicationId, true);
                break;

              case 'SNOOZE':
                print('Medication $medicationId snoozed');

                final snoozeDuration =
                    _calculateSmartSnoozeDuration(missedCount);
                final newTime = DateTime.now().add(snoozeDuration);
                final newId = newTime.millisecondsSinceEpoch.remainder(100000);
                final newMissedCount = missedCount + 1;

                await AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: newId,
                    channelKey: 'medication_channel',
                    title: 'Snoozed: Medication Reminder',
                    body:
                        'This is a snoozed reminder to take your medication (Missed: $newMissedCount times)',
                    notificationLayout: NotificationLayout.Default,
                    payload: {
                      'medication_id': medicationId ?? '',
                      'original_id': originalId ?? '',
                      'missed_count': newMissedCount.toString(),
                      'next_dose_time': nextDoseTime,
                    },
                  ),
                  schedule: NotificationCalendar.fromDate(
                      date: tz.TZDateTime.from(newTime, tz.local)),
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

                await _updateMedicationStatus(
                    medicationId, false, newMissedCount);
                break;

              case 'SKIP':
                print('Medication $medicationId skipped');
                await _updateMedicationStatus(
                    medicationId, false, missedCount + 1);

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
                }
                break;
            }
          } catch (e) {
            print('❌ Error in notification action handler: $e');
          }
        },
      );
      print('✅ Notification listeners set up');
    } catch (e) {
      print('⚠️ Notification listeners setup failed: $e');
    }

    print('🎯 Starting app...');
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
  } catch (e, stackTrace) {
    print('💥 CRITICAL ERROR in main(): $e');
    print('Stack trace: $stackTrace');

    // Fallback: Run a minimal app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text('App initialization failed'),
                SizedBox(height: 8),
                Text('Error: $e', style: TextStyle(fontSize: 12)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    main();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building MyApp widget...');

    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        print('🎨 Consumer2 builder called');

        try {
          return MaterialApp(
            title: 'MedTrack',
            theme: _getSafeTheme(themeProvider),
            locale: _getSafeLocale(languageProvider),
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
            home: _buildHome(),
          );
        } catch (e) {
          print('❌ Error building MaterialApp: $e');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    Text('App Error: $e'),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      ),
                      child: Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  ThemeData _getSafeTheme(ThemeProvider? themeProvider) {
    try {
      return themeProvider?.getTheme() ?? ThemeData.light();
    } catch (e) {
      print('⚠️ Error getting theme, using default: $e');
      return ThemeData.light();
    }
  }

  Locale _getSafeLocale(LanguageProvider? languageProvider) {
    try {
      return languageProvider?.currentLocale ?? const Locale('en');
    } catch (e) {
      print('⚠️ Error getting locale, using English: $e');
      return const Locale('en');
    }
  }

  Widget _buildHome() {
    print('🏠 Building home widget...');

    return FutureBuilder<bool>(
      future: _checkBiometricLock(),
      builder: (context, snapshot) {
        print('🏠 FutureBuilder state: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ Error checking biometric lock: ${snapshot.error}');
          return const HomeScreen(); // Fallback to home screen
        }

        final bool isBiometricLockEnabled = snapshot.data ?? false;
        print('🔒 Biometric lock enabled: $isBiometricLockEnabled');

        try {
          return isBiometricLockEnabled
              ? const LockScreen()
              : const HomeScreen();
        } catch (e) {
          print('❌ Error creating home/lock screen: $e');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home, size: 48),
                  const Text('Welcome to MedTrack'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<bool> _checkBiometricLock() async {
    try {
      print('🔒 Checking biometric lock setting...');
      final prefs = await SharedPreferences.getInstance();
      final result = prefs.getBool('biometric_lock') ?? false;
      print('🔒 Biometric lock result: $result');
      return result;
    } catch (e) {
      print('❌ Error checking biometric lock: $e');
      return false; // Default to no lock if error
    }
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
Future<void> _updateMedicationStatus(String? medicationId, bool isConfirmed,
    [int missedCount = 0]) async {
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
Future<void> _scheduleNextDose(
    String? medicationId, DateTime nextDoseTime) async {
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
    schedule: NotificationCalendar.fromDate(
        date: tz.TZDateTime.from(nextDoseTime, tz.local)),
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
