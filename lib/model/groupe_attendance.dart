import 'package:madrassa/model/student_attendance.dart';

import 'admin.dart';

class GroupeAttendance {
  String id;
  DateTime date;
  List<StudentAttendance> studentAttendances;
  Admin createdBy;
  DateTime createdAt,updatedAt;


  GroupeAttendance({
    required this.id,
    required this.date,
    required this.studentAttendances,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a GroupeAttendance object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy.toMap(),
      'studentAttendances': studentAttendances.map((sa) => sa.toMap()).toList(),
    };
  }

  // Create a GroupeAttendance object from a Map
  static GroupeAttendance fromMap(Map<String, dynamic> map) {
    return GroupeAttendance(
      id: map['id'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: Admin.fromMap(map['createdBy']),
      studentAttendances: (map['studentAttendances'] as List)
          .map((item) => StudentAttendance.fromMap(item))
          .toList(),
    );
  }
}
