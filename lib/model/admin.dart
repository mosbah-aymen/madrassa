import 'package:madrassa/constants/enums.dart';

class Admin {
  String id;
  String name;
  String email;
  String phone;
  Role role;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // Convert Admin object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
    };
  }

  // Create an Admin object from a map retrieved from Firestore
  factory Admin.fromMap(Map<String, dynamic> data) {
    return Admin(
      id: data['id']??'',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] == Role.administrateur.name ? Role.administrateur : Role.secretaire,
    );
  }
}
