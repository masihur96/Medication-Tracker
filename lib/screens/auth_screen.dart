import 'package:flutter/material.dart';
import 'package:med_track/screens/forgot_password_screen.dart';


import 'dashboard_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBloodGroup;
  bool _isSignIn = true;
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo and Title Section
                  Column(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'MedTrack',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignIn ? 'Welcome back!' : 'Create your account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Form Fields
                  if (!_isSignIn) ...[
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person,
                      validator: (value) {
                        if (!_isSignIn && (value == null || value.isEmpty)) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Enter your age',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!_isSignIn && (value == null || value.isEmpty)) {
                          return 'Please enter your age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      hint: 'Enter your height',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!_isSignIn && (value == null || value.isEmpty)) {
                          return 'Please enter your height';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: 'Enter your weight',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (!_isSignIn && (value == null || value.isEmpty)) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildBloodGroupDropdown(),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      // Simple phone number pattern: digits only, 10 to 15 digits
                      final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');

                      if (!phoneRegExp.hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign In/Up Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isSignIn ? 'Sign In' : 'Sign Up'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Toggle Sign In/Up
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignIn = !_isSignIn;
                      });
                    },
                    child: Text(
                      _isSignIn
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Sign In',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  if (_isSignIn)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: InputDecoration(
        labelText: 'Blood Group',
        prefixIcon: const Icon(Icons.bloodtype),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: _bloodGroups.map((String bloodGroup) {
        return DropdownMenuItem<String>(
          value: bloodGroup,
          child: Text(bloodGroup),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodGroup = newValue;
        });
      },
      validator: (value) {
        if (!_isSignIn && value == null) {
          return 'Please select your blood group';
        }
        return null;
      },
    );
  }

  void _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (_isSignIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        final userData = {
          'fullName': _fullNameController.text,
          'age': int.parse(_ageController.text),
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'bloodGroup': _selectedBloodGroup,
          'phoneNumber': _phoneController.text,
        };
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
} 