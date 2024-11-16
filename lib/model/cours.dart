import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/subject.dart';
import 'package:madrassa/model/teacher.dart';
import 'package:madrassa/model/groupe.dart'; // Import the Group model
class Cours {
  String id;
  String name;
  Teacher teacher;
  List<Group> groups; // Updated to List<Group>
  bool isRepeat;
  Subject subject;
  Level level;
  String year;
  DateTime createdAt;
  List<DateTimeRange> daysWeek;
  int price;
  int nombreSeance;

  double get totalCostPerSeance => price / nombreSeance;

  Cours({
    required this.id,
    required this.name,
    required this.teacher,
    required this.groups, // Updated to List<Group>
    required this.isRepeat,
    required this.subject,
    required this.level,
    required this.year,
    required this.daysWeek,
    required this.createdAt,
    required this.price,
    required this.nombreSeance,
  });

  factory Cours.fromMap(Map<String, dynamic> data) {
    return Cours(
      id: data['id']??"",
      name: data['name'] ?? '',
      teacher: Teacher.fromMap(data['teacher']),
      groups: List.generate(data['groups']==null?0:data['groups'].length, (index) {
        var group = Group.fromMap(data['groups'][index]);
        group.cours = null; // Set cours to this Cours object
        return group;
      }),
      isRepeat: data['isRepeat'] ?? false,
      price: data['price'] ?? 0,
      nombreSeance: data['nombreSeance'] ?? 0,
      year: data['year'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      subject: Subject.fromMap(data['subject']),
      level: Level.values.firstWhere(
            (e) => e.toString() == data['level'],
        orElse: () => Level.autre,
      ),
      daysWeek: (data['daysWeek'] as List)
          .map((rangeMap) {
        final startAt = (rangeMap['startAt'] as Timestamp).toDate();
        final finishAt = (rangeMap['finishAt'] as Timestamp).toDate();
        return DateTimeRange(start: startAt, end: finishAt);
      })
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    for (var group in groups) {
      group.cours = null; // Temporarily set cours to null to avoid circular reference
    }
    final map = {
      'id':id,
      'name': name,
      'teacher': teacher.toMap(),
      'isRepeat': isRepeat,
      'price': price,
      'nombreSeance': nombreSeance,
      'year': year,
      'groups': groups.map((group) => group.toMap()).toList(),
      'subject': subject.toMap(),
      'level': level.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'daysWeek': daysWeek.map((range) {
        return {
          'startAt': Timestamp.fromDate(range.start),
          'finishAt': Timestamp.fromDate(range.end),
        };
      }).toList(),
    };
    for (var group in groups) {
      group.cours = this; // Restore the cours reference
    }
    return map;
  }
}
