import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/subject.dart';

class Teacher {
  String id;
  String name;
  String email;
  String phone;
  Subject subject;
  Level level;
  Sex sex;
  DateTime createdAt; // Add createdAt field

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.level,
    required this.sex,
    required this.createdAt, // Include createdAt in the constructor
  });

  // Convert from Firestore document to Teacher object
  factory Teacher.fromMap(Map<String, dynamic> data) {
    return Teacher(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      sex: data['sex'] == Sex.male.name ? Sex.male : Sex.female,
      subject: Subject.fromMap(data['subject']),
      level: Level.values.firstWhere(
        (e) => e.toString() == data['level'],
        orElse: () => Level.autre,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }

  // Convert Teacher object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject.toMap(),
      'sex': sex.name,
      'level': level.toString(),
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
    };
  }
}
