import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/room.dart';
class Group {
  String id;
  String name;
  Cours? cours; // The course associated with the group
  List<Student> students; // List of students in the group
  List<GroupeAttendance> groupeAttendance=[];
  Room? room; // The room where the group meets
  List<DateTimeRange> schedule; // Times when the group meets
  List<RepeatedDay>? repeatedDaysOfWeek; // List of repeated days with detailed information

  Group({
    required this.id,
    required this.name,
    required this.cours, // Course associated with the group
    required this.students, // List of students
    required this.groupeAttendance, // List of students
    this.room, // Optional room
    required this.schedule, // List of meeting times
    this.repeatedDaysOfWeek, // Optional list of detailed repeated days
  });

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      cours: data['cours'] != null ? Cours.fromMap(data['cours']) : null, // Convert Map to Cours, check if not null
      students: (data['students'] as List)
          .map((studentMap) => Student.fromMap(studentMap)) // Convert Map to Student
          .toList(),
      room: data['room'] == null ? null : Room.fromJson(data['room']),
      groupeAttendance:data['groupeAttendance']==null?[]:(data['groupeAttendance'] as List)
          .map((groupeAttendance) => GroupeAttendance.fromMap(groupeAttendance)) // Convert Map to Student
          .toList(),
      schedule: (data['schedule'] as List)
          .map((rangeMap) {
        final startAt = (rangeMap['startAt'] as Timestamp).toDate();
        final finishAt = (rangeMap['finishAt'] as Timestamp).toDate();
        return DateTimeRange(start: startAt, end: finishAt);
      }).toList(),
      repeatedDaysOfWeek: (data['repeatedDaysOfWeek'] as List<dynamic>?)
          ?.map((dayMap) => RepeatedDay.fromMap(dayMap))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
      'cours': cours?.toMap(), // Convert Cours to Map if not null
      'students': students.map((student) {
        student.groups=[];
        return student.toMap();
      }).toList(), // Convert Student to Map
      'room': room?.toJson(),
      'schedule': schedule.map((range) {
        return {
          'startAt': Timestamp.fromDate(range.start),
          'finishAt': Timestamp.fromDate(range.end),
        };
      }).toList(),
      'repeatedDaysOfWeek': repeatedDaysOfWeek?.map((day) => day.toMap()).toList() ?? [], // Convert RepeatedDay to Map
    };
  }
}
class RepeatedDay {
  String id;
  TimeOfDay start;
  TimeOfDay end;
  int dayIndex; // Day of the week as an integer (1 = Monday, 7 = Sunday)
  String dayNameFr; // French name of the day
  String dayNameAr; // Arabic name of the day
  DateTime nextDay; // The next occurrence of this day

  RepeatedDay({
    required this.id,
    required this.start,
    required this.end,
    required this.dayIndex,
    required this.dayNameFr,
    required this.dayNameAr,
    required this.nextDay,
  });

  factory RepeatedDay.fromMap(Map<String, dynamic> data) {
    return RepeatedDay(
      id: data['id'] ?? '',
      start: TimeOfDay(
        hour: (data['start']['hour'] as int?) ?? 0,
        minute: (data['start']['minute'] as int?) ?? 0,
      ),
      end: TimeOfDay(
        hour: (data['end']['hour'] as int?) ?? 0,
        minute: (data['end']['minute'] as int?) ?? 0,
      ),
      dayIndex: data['dayIndex'] ?? 1,
      dayNameFr: data['dayNameFr'] ?? '',
      dayNameAr: data['dayNameAr'] ?? '',
      nextDay: (data['nextDay'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': {'hour': start.hour, 'minute': start.minute},
      'end': {'hour': end.hour, 'minute': end.minute},
      'dayIndex': dayIndex,
      'dayNameFr': dayNameFr,
      'dayNameAr': dayNameAr,
      'nextDay': Timestamp.fromDate(nextDay),
    };
  }
}
