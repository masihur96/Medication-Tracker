import 'package:dio/dio.dart';
import 'package:med_track/models/medication.dart';
import 'package:med_track/models/prescription.dart';
import 'package:med_track/models/user_profile.dart';

class SupabaseService {
  static const _supabaseUrl = 'https://ykbpugszryxnhzotaoue.supabase.co';
  static const _apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrYnB1Z3N6cnl4bmh6b3Rhb3VlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5NzAxNzQsImV4cCI6MjA2NzU0NjE3NH0.1Oolf9bu9vLf0KrdQ2drMHSBp2H5lFggezfIcdkzSO0';

  static const _prescriptionTable = 'prescriptions';
  static const _medicationTable = 'medications';
  static const _profileTable = 'user_profiles';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: '$_supabaseUrl/rest/v1/',
    headers: {
      'apikey': _apiKey,
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
  ));

  /// Upload prescription and latest medication to Supabase
  Future<void> uploadPrescriptionToSupabase(Prescription prescription) async {
    try {
      // 1. Check if prescription already exists
      final checkResponse = await _dio.get(
        _prescriptionTable,
        queryParameters: {
          'prescription_uid': 'eq.${prescription.uid}',
          'select': 'prescription_uid',
          'limit': 1,
        },
      );

      final exists = (checkResponse.data as List).isNotEmpty;
      print('Prescription exists: $exists');

      // 2. Insert prescription if not exists
      if (!exists) {
        final prescriptionData = {
          'prescription_uid': prescription.uid,
          'doctor': prescription.doctor,
          'date': prescription.date,
          'patient': prescription.patient,
          'age': prescription.age,
          'created_at': DateTime.now().toIso8601String(),
        };

        print("prescriptionData: $prescriptionData");
        await _dio.post(_prescriptionTable, data: prescriptionData);
      }

      // 3. Insert the last medication (or loop for all if needed)
      final Medication med = prescription.medications.last;

      final medicationData = {
        'prescription_uid': prescription.uid,
        'name': med.name,
        'stock': med.stock,
        'timesperday': med.timesPerDay,
        'isactive': med.isActive,
        'istaken': false, // ✅ Default or adjust if needed
        'notes': med.notes,
      };

      print("medicationData: $medicationData");

      await _dio.post(_medicationTable, data: medicationData);
    } catch (e) {
      if (e is DioException) {
        print('DioException: ${e.response?.data}');
      } else {
        print('Error uploading prescription: $e');
      }
    }
  }

  /// Upload user profile using Supabase client
  Future<void> uploadUserProfile(UserProfile profile) async {


    try {

      print('Profile uploaded: ${ profile.toMap()}');
      await _dio.post(_profileTable, data: profile.toMap());


      print('Profile uploaded: ${profile.name}');
    } catch (e) {
      if (e is DioException) {
        print('Supabase Error Message: ${e.response?.data}');
      }
    }
  }
}
