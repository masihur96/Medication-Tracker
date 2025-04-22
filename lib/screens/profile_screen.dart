import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  String? _profileImagePath;
  
  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _ageController.text = prefs.getString('age') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _emergencyContactController.text = prefs.getString('emergencyContact') ?? '';
      _allergiesController.text = prefs.getString('allergies') ?? '';
      _bloodGroupController.text = prefs.getString('bloodGroup') ?? '';
      _profileImagePath = prefs.getString('profileImage');
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Copy image to app directory for permanent storage
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final String localPath = '${appDir.path}/$fileName';
      
      // Copy the picked image to the app directory
      await File(image.path).copy(localPath);
      
      setState(() {
        _profileImagePath = localPath;
      });
      
      // Save the image path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', localPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditMode) {
                  // Save the changes here
                  _saveChanges();
                }
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildProfilePicture(),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionTitle('Personal Information'),
            _buildReadOnlyField(
              'Full Name',
              _nameController,
              Icons.person,
            ),
            _buildReadOnlyField(
              'Age',
              _ageController,
              Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            _buildReadOnlyField(
              'Phone Number',
              _phoneController,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildReadOnlyField(
              'Email',
              _emailController,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            // Medical Information Section
            _buildSectionTitle('Medical Information'),
            _buildReadOnlyField(
              'Blood Group',
              _bloodGroupController,
              Icons.bloodtype,
            ),
            _buildReadOnlyField(
              'Allergies',
              _allergiesController,
              Icons.warning_amber,
              maxLines: 3,
            ),
            _buildReadOnlyField(
              'Emergency Contact',
              _emergencyContactController,
              Icons.emergency,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Settings Section
           // _buildSectionTitle('Settings'),
            // _buildSettingsTile(
            //   'Notification Preferences',
            //   Icons.notifications_outlined,
            // ),
            // _buildSettingsTile(
            //   'Privacy Settings',
            //   Icons.security_outlined,
            // ),
            // _buildSettingsTile(
            //   'Healthcare Provider Details',
            //   Icons.local_hospital_outlined,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: _isEditMode,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: !_isEditMode,
          // fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: _isEditMode ? () {
        // Navigate to respective settings screen
      } : null,
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: _profileImagePath != null 
                ? FileImage(File(_profileImagePath!))
                : null,
            child: _profileImagePath == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          if (_isEditMode)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    if (_profileImagePath != null) {
      await prefs.setString('profileImage', _profileImagePath!);
    }
    await prefs.setString('name', _nameController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('emergencyContact', _emergencyContactController.text);
    await prefs.setString('allergies', _allergiesController.text);
    await prefs.setString('bloodGroup', _bloodGroupController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _allergiesController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }
} 