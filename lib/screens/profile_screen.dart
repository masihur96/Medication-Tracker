import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  
  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController(text: 'John Doe'); // Example default value
  final TextEditingController _ageController = TextEditingController(text: '30');
  final TextEditingController _phoneController = TextEditingController(text: '+1234567890');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _emergencyContactController = TextEditingController(text: '+1987654321');
  final TextEditingController _allergiesController = TextEditingController(text: 'None');
  final TextEditingController _bloodGroupController = TextEditingController(text: 'O+');

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
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  if (_isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                ],
              ),
            ),
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
            _buildSectionTitle('Settings'),
            _buildSettingsTile(
              'Notification Preferences',
              Icons.notifications_outlined,
            ),
            _buildSettingsTile(
              'Privacy Settings',
              Icons.security_outlined,
            ),
            _buildSettingsTile(
              'Healthcare Provider Details',
              Icons.local_hospital_outlined,
            ),
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
          fillColor: Colors.grey[200],
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

  void _saveChanges() {
    // Implement save functionality here
    // You can save to local storage or make an API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully')),
    );
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