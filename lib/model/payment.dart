import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/promotion_type.dart';
import 'package:madrassa/model/student.dart';

class Payment {
  String id;
  Student student;
  Group groupe;
  int amount;
  DateTime date;
  int sessionNumber;
  PromotionTypeEnum? promotionType; // New optional field

  Payment({
    required this.id,
    required this.student,
    required this.groupe,
    required this.amount,
    required this.date,
    required this.sessionNumber,
    this.promotionType,
  });

  factory Payment.fromMap(Map<String, dynamic> data, String documentId) {
    return Payment(
      id: documentId,
      student: Student.fromMap(data['student']),
      groupe: Group.fromMap(data['groupe']),
      amount: data['amount'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      sessionNumber: data['sessionNumber'] ?? 0,
      promotionType:data['promotionType']==null?null: PromotionTypeEnum.values.byName(data['promotionType']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student': student.toMap(),
      'groupe': groupe.toMap(),
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'sessionNumber': sessionNumber,
      'promotionType': promotionType?.name, // Convert enum to string
    };
  }
}
