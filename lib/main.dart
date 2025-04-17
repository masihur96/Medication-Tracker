
import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/screens/auth_screen.dart';
import 'package:med_track/screens/home_screen.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


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