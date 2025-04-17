import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/screens/new_rx_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_medication_screen.dart';

class RxScreen extends StatefulWidget {
  const RxScreen({super.key});

  @override
  State<RxScreen> createState() => _RxScreenState();
}

class _RxScreenState extends State<RxScreen> {
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
      final List decoded = jsonDecode(listString);
      final List<Prescription> loaded =
          decoded.map((e) => Prescription.fromJson(e)).toList();
      setState(() {
        _prescriptions = loaded;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Prescriptions',
          style: TextStyle(
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
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No prescriptions found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
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
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                              child: const Icon(
                                                Icons.medication,
                                                color: Colors.white,
                                                size: 35,

                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              rx.date,
                                              style: TextStyle(
                                                color: Colors.grey[600],
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
                                              Text(
                                                rx.medication,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                rx.doctor,
                                                style: const TextStyle(color: Colors.black87),
                                              ),
                                              Text(
                                                'Ch: ${rx.chamber}',
                                                style: const TextStyle(color: Colors.black87),
                                              ),
                                              Text(
                                                'Pt: ${rx.patient}',
                                                style: const TextStyle(color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios),
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewRxScreen(),
            ),
          );
          loadPrescriptions();
        },
        icon: const Icon(Icons.add,color: Colors.white),
        label: const Text('Add Prescription',style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
