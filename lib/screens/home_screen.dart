import 'package:flutter/material.dart';
import 'package:med_track/providers/medication_provider.dart';
import 'package:med_track/widgets/medication_card.dart';
import 'package:provider/provider.dart';

import 'add_medication_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('MedTrack'),),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(

          child: Icon(Icons.add),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMedicationScreen()),
          ),
        ),
        body: Column(
          children: [
            // Today's medications
            Expanded(
              child: Consumer<MedicationProvider>(
                builder: (ctx, medProvider, _) => ListView.builder(
                  itemCount: medProvider.medications.length,
                  itemBuilder: (ctx, i) => MedicationCard(
                    medication: medProvider.medications[i],
                  ),
                ),
              ),
            ),
            // Add medication button

          ],
        ),
      ),
    );
  }
}