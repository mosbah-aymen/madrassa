import 'package:madrassa/constants/enums.dart';
class Student {
  String id;
  String name;
  String classId;
  String email;
  String phone1,phone2;
  Sex sex;
  bool isEnrolled;

  Student({
    required this.id,
    required this.name,
    required this.classId,
    required this.email,
    required this.phone1,
    required this.phone2,
    required this.sex,
    required this.isEnrolled,
  });

  // Convert from Firestore document to Student object
  factory Student.fromMap(Map<String, dynamic> data, String documentId) {
    return Student(
      id: documentId,
      name: data['name'] ?? '',
      classId: data['classId'] ?? '',
      email: data['email'] ?? '',
      phone1: data['phone1'] ?? '',
      phone2: data['phone2'] ?? '',
      sex: data['sex']==Sex.male.name?Sex.male:Sex.female,
      isEnrolled: data['isEnrolled'] ?? true,
    );
  }

  // Convert Student object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classId': classId,
      'email': email,
      'phone': phone1,
      'phone2': phone2,
      'sex': sex.name,
      'isEnrolled': isEnrolled,
    };
  }
}
