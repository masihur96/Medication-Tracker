import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/screens/settings_screen.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'medication_schedule_screen.dart';
import 'medication_screen.dart';
import 'rx_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    DashboardScreen(),
    MedicationScreen(),
    RxScreen(),
    MedicationScheduleScreen(),
    SettingsScreen(),
  ];

  Future<void> _initializeData() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // Column(
      //   children: [
      //     // Today's medications
      //     Expanded(
      //       child: Consumer<MedicationProvider>(
      //         builder: (ctx, medProvider, _) => ListView.builder(
      //           itemCount: medProvider.medications.length,
      //           itemBuilder: (ctx, i) => MedicationCard(
      //             medication: medProvider.medications[i],
      //           ),
      //         ),
      //       ),
      //     ),
      //     // Add medication button
      //
      //   ],
      // ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: AppLocalizations.of(context).dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: AppLocalizations.of(context).drug,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_outlined),
            label: AppLocalizations.of(context).rx,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: AppLocalizations.of(context).schedule,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: AppLocalizations.of(context).settings,
          ),
        ],
      ),
    );
  }
}