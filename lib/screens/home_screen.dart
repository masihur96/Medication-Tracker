import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/screens/profile_screen.dart';
import 'package:med_track/widgets/medication_card.dart';
import 'package:provider/provider.dart';

import 'add_medication_screen.dart';
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
    ProfileScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_rounded),
            label: 'Rx',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}