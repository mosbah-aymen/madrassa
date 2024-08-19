import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  String id;
  String studentId;
  String classId;
  DateTime date;
  bool isPresent;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.isPresent,
  });

  factory Attendance.fromMap(Map<String, dynamic> data, String documentId) {
    return Attendance(
      id: documentId,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isPresent: data['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
    };
  }
}
