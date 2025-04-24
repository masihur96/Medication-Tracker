import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/new_rx_screen.dart';
import 'package:med_track/screens/prescription_details_screen.dart';
import 'package:med_track/services/local_repository.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_medication_screen.dart';


class RxScreen extends StatefulWidget {
  const RxScreen({super.key});

  @override
  State<RxScreen> createState() => _RxScreenState();
}

class _RxScreenState extends State<RxScreen> {

  final LocalRepository _localRepository = LocalRepository();
  List<Prescription> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrescriptions();
  }

  Future<void> loadPrescriptions() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {

        try{
          final List decoded = jsonDecode(listString);
          final List<Prescription> loaded =
          decoded.map((e) => Prescription.fromJson(e)).toList();
          setState(() {
            _prescriptions = loaded;
            _isLoading = false;
          });
        }catch(e){
          print("loadPrescriptions$e");
        }

      } else {
        setState(() => _isLoading = false);
      }



  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          localizations.rx,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: _prescriptions.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.noPrescriptionsFound,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final rx = _prescriptions[index];
                              return Slidable(
                                key: ValueKey(rx.uid),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async{

                                       await _localRepository.deletePrescription(rx.uid);
                                       await loadPrescriptions();

                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PrescriptionDetailsScreen(prescription: rx),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                  radius: 30,
                                                  child: Text(
                                                    "Rx",
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  rx.date,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  const SizedBox(height: 4),
                                                  Text(
                                                    rx.doctor,
                                                  ),

                                                  Text(
                                                    'Pt: ${rx.patient}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.medication_outlined,size: 40,),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => AddMedicationScreen(prescription: rx),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _prescriptions.length,
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {

         String uuid =  DateTime.now().microsecondsSinceEpoch.toString();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  NewRxScreen(uuid: uuid,),
            ),
          );
          loadPrescriptions();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          localizations.addMedication,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
