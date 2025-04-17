import 'package:flutter/material.dart';
import 'package:med_track/models/prescription.dart';


class AddMedicationScreen extends StatefulWidget {

  final Prescription prescription;

  const AddMedicationScreen({super.key,required this.prescription});
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();
  final _noteController = TextEditingController();
  String _frequency = 'Daily'; // Default frequency
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isActive = true;
  List<int> _selectedTimes = [];

  // List of frequency options
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly', 'As needed'];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedTimes = [picked.hour * 60 + picked.minute];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medication', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rx Text on Left
                    Column(
                      children: [
                        Text(
                          'Rx',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        _buildLineField(label: widget.prescription.date,size: 16),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Patient Info on Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLineField(label: 'DR: ${widget.prescription.doctor}',size: 16),
                          // SizedBox(height: 12),
                          _buildLineField(label: 'Ch: ${widget.prescription.chamber}',size: 12),

                          Divider(
                          ),
                          _buildLineField(label: 'Name: ${widget.prescription.patient}',size: 16),
                          _buildLineField(label: 'To: ${widget.prescription.medication}',size: 12),

                        ],
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.black87),
              ],
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule & Stock',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Medication Stock',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (int.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _frequencyOptions.map((String frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _frequency = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Reminder Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any additional instructions or notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Medication Status'),
                      subtitle: Text(_isActive ? 'Active' : 'Inactive'),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Medication',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildLineField({required String label,required double size}) {
  return Text(
    label,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w500),
  );
}


