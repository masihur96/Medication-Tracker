import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/services/notification_service.dart';
import 'package:med_track/utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AddMedicationScreen extends StatefulWidget {
  final Prescription prescription;
  final Medication? medication;

  const AddMedicationScreen({super.key,required this.prescription,this.medication});
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // Add these constants at the top of the class
  static const String FREQUENCY_DAILY = 'daily';
  static const String FREQUENCY_WEEKLY = 'weekly';
  static const String FREQUENCY_MONTHLY = 'monthly';
  static const String FREQUENCY_AS_NEEDED = 'as_needed';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _stockController = TextEditingController();
  final _noteController = TextEditingController();
  // final _durationController = TextEditingController();
  String _frequency = FREQUENCY_DAILY; // Change default value to use constant

  int _timesPer = 1; // Default frequency
  final List<TimeOfDay> _selectedTimes = [TimeOfDay.now()];
  final List<bool> _isTaken = [false];

  List<String> _selectedWeekdays = [];
  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<int> _selectedMonthDays = [];


  // final DateTime _reminderDates=[];

  List<String> _reminderDates = [];

  // Add these new variables
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    // Initialize form fields if medication exists
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;

      _stockController.text = widget.medication!.stock.toString();
      _noteController.text = widget.medication!.notes!;
      _frequency = _getFrequencyConstant(widget.medication!.frequency);
      _timesPer = widget.medication!.timesPerDay;
      _selectedTimes.clear();
      _selectedTimes.addAll(widget.medication!.reminderTimes);
      _isTaken.clear();
      _isTaken.addAll(widget.medication!.isTaken);
      // _durationController.text = widget.medication!.duration.toString();
      // _startDate = widget.medication!.startDate;
      // _endDate = widget.medication!.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _noteController.dispose();
    // _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  // Add this method to build time selection fields
  List<Widget> _buildTimeFields() {
    return List.generate(_timesPer, (index) {
      // Ensure we have enough times and status in our lists
      while (_selectedTimes.length < _timesPer) {
        _selectedTimes.add(TimeOfDay.now());
        _isTaken.add(false);
      }
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < _timesPer - 1 ? 16 : 0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, index),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Reminder Time ${index + 1}',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(_selectedTimes[index].format(context)),
                ),
              ),
            ),
            SizedBox(width: 16),
            Checkbox(
              value: _isTaken[index],
              onChanged: (bool? value) {
                setState(() {
                  _isTaken[index] = value ?? false;
                });
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.medication != null ? localizations.edit : localizations.newRx,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [

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
                      localizations.prescriptionDetails,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.medicationName,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) => value!.isEmpty ? localizations.required : null,
                    ),
                    SizedBox(height: 16),


                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: localizations.stock,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return localizations.required;
                        if (int.tryParse(value) == null) return localizations.enterValidNumber;
                        return null;
                      },
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
                      localizations.schedule,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    _buildDateRangeSelector(),

                    SizedBox(height: 16),
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _frequency,
                          decoration: InputDecoration(
                            labelText: localizations.frequency,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: [
                            _buildFrequencyMenuItem(FREQUENCY_DAILY, localizations.daily),
                            _buildFrequencyMenuItem(FREQUENCY_WEEKLY, localizations.weekly),
                            _buildFrequencyMenuItem(FREQUENCY_MONTHLY, localizations.monthly),
                            _buildFrequencyMenuItem(FREQUENCY_AS_NEEDED, localizations.asNeeded),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _frequency = newValue!;
                              _reminderDates = [];
                            });
                            generateDatesBasedOnFrequency();
                          },
                        ),
                        if (_frequency == FREQUENCY_WEEKLY) _buildWeeklySelector(),
                        if (_frequency == FREQUENCY_MONTHLY) _buildMonthlySelector(),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _timesPer,
                      decoration: InputDecoration(
                        labelText: localizations.timesPerDay,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: [1,2,3].map((int times) {
                        return DropdownMenuItem(
                          value: times,
                          child: Text(times.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _timesPer = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ..._buildTimeFields(),
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
                      localizations.additionalInfo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: localizations.notes,
                        hintText: localizations.additionalInstructions,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async{
                if (_formKey.currentState!.validate()) {



                  final prescription = Prescription(

                    uid: widget.prescription.uid,
                    doctor: widget.prescription.doctor,
                    date:  DateFormat('d MMM y').format(DateTime.now()) ,

                    patient: widget.prescription.patient,
                    age: widget.prescription.age,
                    medications: widget.prescription.medications..add(
                      Medication(
                        id: widget.medication?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        timesPerDay: _timesPer,
                        stock: int.parse(_stockController.text),
                        isActive: true,
                        notes: _noteController.text,
                        frequency: _getDisplayFrequency(_frequency, AppLocalizations.of(context)),
                        reminderTimes: _selectedTimes,
                        remainderDates: _reminderDates,
                        isTaken: _isTaken,
                      ),
                    ),
                  );

              await    savePrescription(prescription);
              await setScheduleNotification();
                  Navigator.pop(context);

                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.medication != null ? localizations.updatePrescription : localizations.saveMedication,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> savePrescription(Prescription prescription) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing list
    final String? existingListString = prefs.getString('prescriptions');
    List<Prescription> prescriptions = [];

    if (existingListString != null) {
      final List decodedList = jsonDecode(existingListString);
      prescriptions = decodedList.map((e) => Prescription.fromJson(e)).toList();
    }

    // If editing, remove the old prescription
    if (widget.prescription != null) {
      prescriptions.removeWhere((p) => p.uid == widget.prescription.uid);
    }
    // Add the prescription (new or updated)
    prescriptions.add(prescription);
    // Save updated list
    final String encodedList =
    jsonEncode(prescriptions.map((e) => e.toJson()).toList());
    await prefs.setString('prescriptions', encodedList);


  }


  Future<void> addMedicationToPrescription(String uid, Medication med) async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();

      final index = prescriptions.indexWhere((rx) => rx.uid == uid);
      if (index != -1) {
        prescriptions[index].medications.add(med);

        // Save updated list back
        final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
        await prefs.setString('prescriptions', updatedString);
      }
    }
  }

  Future<void> updateMedicationInPrescription(String uid, Medication med) async {
    final prefs = await SharedPreferences.getInstance();
    final String? listString = prefs.getString('prescriptions');

    if (listString != null) {
      List decoded = jsonDecode(listString);
      List<Prescription> prescriptions = decoded
          .map((e) => Prescription.fromJson(e))
          .toList();

      final prescriptionIndex = prescriptions.indexWhere((rx) => rx.uid == uid);
      if (prescriptionIndex != -1) {
        final medicationIndex = prescriptions[prescriptionIndex].medications
            .indexWhere((m) => m.id == med.id);
        
        if (medicationIndex != -1) {
          // Replace the existing medication
          prescriptions[prescriptionIndex].medications[medicationIndex] = med;

          // Save updated list back
          final updatedString = jsonEncode(prescriptions.map((e) => e.toJson()).toList());
          await prefs.setString('prescriptions', updatedString);
        }
      }
    }
  }



  Widget _buildWeeklySelector() {
    return Wrap(
      spacing: 8,
      children: _weekdays.map((day) {
        return FilterChip(
          label: Text(day),
          selected: _selectedWeekdays.contains(day),
          onSelected: (selected) {
            setState(() {
              selected
                  ? _selectedWeekdays.add(day)
                  : _selectedWeekdays.remove(day);
            });
            generateDatesBasedOnFrequency();
          },
        );
      }).toList(),
    );
  }

  Widget _buildMonthlySelector() {
    return Wrap(
      spacing: 8,
      children: List.generate(31, (index) {
        int day = index + 1;
        return FilterChip(
          label: Text('$day'),
          selected: _selectedMonthDays.contains(day),
          onSelected: (selected) {
            setState(() {
              selected
                  ? _selectedMonthDays.add(day)
                  : _selectedMonthDays.remove(day);
            });
            generateDatesBasedOnFrequency();
          },
        );
      }),
    );
  }

  void generateDatesBasedOnFrequency() {
    List<String> generatedDates = [];

    if (_frequency == FREQUENCY_DAILY) {
      for (var date = _startDate;
          date.isBefore(_endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        generatedDates.add(_formatDate(date));
      }
    } else if (_frequency == FREQUENCY_WEEKLY) {
      Map<String, int> weekdayMap = {
        'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4,
        'Fri': 5, 'Sat': 6, 'Sun': 7,
      };

      for (var date = _startDate;
          date.isBefore(_endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        if (_selectedWeekdays
            .map((d) => weekdayMap[d])
            .contains(date.weekday)) {
          generatedDates.add(_formatDate(date));
        }
      }
    } else if (_frequency == FREQUENCY_MONTHLY) {
      for (var date = _startDate;
          date.isBefore(_endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        if (_selectedMonthDays.contains(date.day)) {
          generatedDates.add(_formatDate(date));
        }
      }
    }
    setState(() {
      _reminderDates = generatedDates;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DropdownMenuItem<String> _buildFrequencyMenuItem(String value, String text) {
    return DropdownMenuItem(
      value: value,
      child: Text(text),
    );
  }

  String _getDisplayFrequency(String frequencyConstant, AppLocalizations localizations) {
    switch (frequencyConstant) {
      case FREQUENCY_DAILY:
        return localizations.daily;
      case FREQUENCY_WEEKLY:
        return localizations.weekly;
      case FREQUENCY_MONTHLY:
        return localizations.monthly;
      case FREQUENCY_AS_NEEDED:
        return localizations.asNeeded;
      default:
        return localizations.daily;
    }
  }

  String _getFrequencyConstant(String storedFrequency) {
    switch (storedFrequency.toLowerCase()) {
      case 'daily':
        return FREQUENCY_DAILY;
      case 'weekly':
        return FREQUENCY_WEEKLY;
      case 'monthly':
        return FREQUENCY_MONTHLY;
      case 'as needed':
        return FREQUENCY_AS_NEEDED;
      default:
        return FREQUENCY_DAILY;
    }
  }



  // Add this new method
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }

        generateDatesBasedOnFrequency();
      });
    }
  }

  // Replace the duration TextFormField in the build method with this new widget
  Widget _buildDateRangeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Start: ${_formatDate(_startDate)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'End: ${_formatDate(_endDate)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> setScheduleNotification() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      final String? listString = prefs.getString('prescriptions');
      if (listString != null) {
        final List decoded = jsonDecode(listString);
        final List<Prescription> loaded =
        decoded.map((e) => Prescription.fromJson(e)).toList();
        // Collect today's medications and schedule notifications
        for (final prescription in loaded) {
          if(prescription.medications.isNotEmpty){
            for (final med in prescription.medications) {
              // Create a list to store all scheduled DateTimes
              List<DateTime> scheduleList = [];
              // For each date, combine with all times
              for (String dateStr in med.remainderDates) {
                // Parse the date string (DD/MM/YYYY format)
                List<String> dateParts = dateStr.split('/');
                int day = int.parse(dateParts[0]);
                int month = int.parse(dateParts[1]);
                int year = int.parse(dateParts[2]);

                // For each time, create a DateTime object
                for (TimeOfDay time in med.reminderTimes) {
                  DateTime scheduledDateTime = DateTime(
                    year,
                    month,
                    day,
                    time.hour,
                    time.minute,
                  );
                  scheduleList.add(scheduledDateTime);
                }
              }
              // Now scheduleList contains all date-time combinations
              log("Scheduled times: $scheduleList");
              // await NotificationScheduler.scheduleAll(scheduleList);
              for (DateTime scheduledDateTime in scheduleList) {
                // Check if the scheduled time is in the future
                if (scheduledDateTime.isAfter(DateTime.now())) {
                  // Generate a unique ID for each notification
                  // Using milliseconds since epoch to ensure uniqueness
                  int notificationId = scheduledDateTime.millisecondsSinceEpoch ~/ 1000;

                  await NotificationService.schedule(
                    scheduledDateTime,
                    notificationId,
                    title: '${med.name} Reminder', // Add medication name
                    body: 'Time to take your medication: ${med.name}\nDosage: ${med.notes}', // Add relevant details
                  );
                }
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error loading prescriptions: $e');
      print('Stack trace: $stackTrace');
    }
  }

}




