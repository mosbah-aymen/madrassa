import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/room.dart';

class Group {
  String id;
  String name;
  Cours? cours;
  List<Student> students;
  List<List<GroupeAttendance>> groupeAttendance; // List of lists of GroupeAttendance
  Room? room;
  List<DateTimeRange> schedule;
  List<RepeatedDay>? repeatedDaysOfWeek;
  double profPercent;

  Group({
    required this.id,
    required this.name,
    required this.cours,
    required this.students,
    required this.groupeAttendance,
    this.room,
    required this.schedule,
    this.repeatedDaysOfWeek,
    required this.profPercent,
  });

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      cours: data['cours'] != null ? Cours.fromMap(data['cours']) : null,
      profPercent: data['profPercent'] ?? 0.0,
      students: (data['students'] as List)
          .map((studentMap) => Student.fromMap(studentMap))
          .toList(),
      room: data['room'] == null ? null : Room.fromJson(data['room']),
      groupeAttendance: (data['groupeAttendance'] as Map<String, dynamic>?)?.values.map((month) {
        return (month as List).map((groupeAttendance) => GroupeAttendance.fromMap(groupeAttendance)).toList();
      }).toList() ?? [],
      schedule: (data['schedule'] as List).map((rangeMap) {
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
      'cours': cours?.toMap(),
      'profPercent': profPercent,
      'students': students.map((student) {
        student.groups = [];
        return student.toMap();
      }).toList(),
      'groupeAttendance': {
        for (int i = 0; i < groupeAttendance.length; i++)
          'month_$i': groupeAttendance[i].map((groupeAttendance) => groupeAttendance.toMap()).toList()
      },
      'room': room?.toJson(),
      'schedule': schedule.map((range) {
        return {
          'startAt': Timestamp.fromDate(range.start),
          'finishAt': Timestamp.fromDate(range.end),
        };
      }).toList(),
      'repeatedDaysOfWeek': repeatedDaysOfWeek?.map((day) => day.toMap()).toList() ?? [],
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

  RepeatedDay({
    required this.id,
    required this.start,
    required this.end,
    required this.dayIndex,
    required this.dayNameFr,
    required this.dayNameAr,
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
    };
  }

  // Helper method to get the next occurrence of a specific day of the week
  DateTime _getNextDateForDay(int day, DateTime currentDate) {
    int daysToAdd = (day - currentDate.weekday) % 7;
    if (daysToAdd <= 0) daysToAdd += 7;
    return currentDate.add(Duration(days: daysToAdd));
  }

  // Getter for the next occurrence of the day
  DateTime get nextDay {
    return _getNextDateForDay(dayIndex, DateTime.now());
  }

  // Getter for the previous occurrence of the day
  DateTime get previousDay {
    DateTime next = nextDay;
    return next.subtract(const Duration(days: 7));
  }

  bool isWithinRange(DateTimeRange range) {
    // Iterate over the days within the DateTimeRange
    DateTime currentDay = range.start;
    while (currentDay.isBefore(range.end)) {
      // Check if the current day matches the dayIndex of the RepeatedDay
      if (currentDay.weekday == dayIndex) {
        return true; // If a match is found, return true
      }
      // Move to the next day
      currentDay = currentDay.add(const Duration(days: 1));
    }
    return false; // If no match is found, return false
  }
}
