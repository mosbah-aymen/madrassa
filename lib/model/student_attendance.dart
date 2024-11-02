import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/student.dart';

import 'admin.dart';

class StudentAttendance {
  String id;
  DateTime date;
  Student student;
  AttendanceStatus status;
  String remarks;
  Admin createdBy;
  DateTime createdAt,updatedAt;

  StudentAttendance({
    required this.id,
    required this.date,
    required this.student,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.remarks,
  });

  // Convert a StudentAttendance object into a Map
  Map<String, dynamic> toMap() {
    student.groups=[];
    return {
      'id': id,
      'date': date.toIso8601String(),
      'student': student.toMap(),
      'status': status.name, // Convert enum to string
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy.toMap(),
      'remarks': remarks,
    };
  }

  // Create a StudentAttendance object from a Map
  factory StudentAttendance.fromMap(Map<String, dynamic> map) {
    return StudentAttendance(
      id: map['id'],
      date: DateTime.parse(map['date']),
      student: Student.fromMap(map['student']),
      status: AttendanceStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: Admin.fromMap(map['createdBy']),
      remarks: map['remarks'],
    );
  }
}
