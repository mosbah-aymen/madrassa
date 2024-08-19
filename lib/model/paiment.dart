import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  String id;
  String studentId;
  String classId;
  double amount;
  DateTime date;

  Payment({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.amount,
    required this.date,
  });

  factory Payment.fromMap(Map<String, dynamic> data, String documentId) {
    return Payment(
      id: documentId,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
