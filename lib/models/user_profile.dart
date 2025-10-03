class UserProfile {
  final String? profileImage;
  final String name;
  final String age;
  final String phone;
  final String email;
  final String emergencyContact;
  final String allergies;
  final String bloodGroup;

  UserProfile({
    this.profileImage,
    required this.name,
    required this.age,
    required this.phone,
    required this.email,
    required this.emergencyContact,
    required this.allergies,
    required this.bloodGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileimage': profileImage,
      'name': name,
      'age': age,
      'phone': phone,
      'email': email,
      'emergencycontact': emergencyContact,
      'allergies': allergies,
      'bloodgroup': bloodGroup,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      profileImage: map['profileimage'],
      name: map['name'],
      age: map['age'],
      phone: map['phone'],
      email: map['email'],
      emergencyContact: map['emergencycontact'],
      allergies: map['allergies'],
      bloodGroup: map['bloodgroup'],
    );
  }
}
