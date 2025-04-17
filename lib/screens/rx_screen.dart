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
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: const Icon(
                                        Icons.medication,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      rx.medication,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dr. ${rx.doctor}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Chamber: ${rx.chamber}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          rx.date,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => AddMedicationScreen()),
                                        );
                                        // TODO: Navigate to prescription details
                                      },
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
