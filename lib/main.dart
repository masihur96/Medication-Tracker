import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await initializeNotifications();

  // Initialize provider
  final medicationProvider = MedicationProvider();
  await medicationProvider.initialize();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: medicationProvider),
      ],
      child: MyApp(),
    ),
  );
}



Future<void> initializeNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  final soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
  final vibrationEnabled = prefs.getBool('notification_vibration_enabled') ?? true;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
      // Handle notification tapped logic here
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        // Add other providers later
      ],
      child: MaterialApp(
        title: 'MedTrack',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}