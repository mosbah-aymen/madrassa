import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/payment.dart';

class PaymentController {
  static final CollectionReference _paymentsCollection =
  FirebaseFirestore.instance.collection('payments');

  // Method to add a payment to Firestore
  static Future<String> addPayment(Payment payment) async {
    String id='';
    try {
      await _paymentsCollection.add(payment.toMap()).then((v){
        id=v.id;
        v.update({
          'id' : id,
        });
      });
      print('Payment added successfully');
      return id;
    } catch (e) {
      print('Error adding payment: $e');
      return id;
    }
  }

  // Method to get a list of all payments for a specific student
  static Future<List<Payment>> getPaymentsForStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _paymentsCollection
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error retrieving payments: $e');
      return [];
    }
  }

  // Method to get all payments for a specific group
  static Future<List<Payment>> getPaymentsForGroup(String groupId) async {
    try {
      QuerySnapshot querySnapshot = await _paymentsCollection
          .where('groupe.id', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error retrieving group payments: $e');
      return [];
    }
  }

  // Method to update a payment record in Firestore
  static Future<void> updatePayment(Payment payment) async {
    try {
      await _paymentsCollection.doc(payment.id).update(payment.toMap());
      print('Payment updated successfully');
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  // Method to delete a payment record from Firestore
  static Future<void> deletePayment(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).delete();
      print('Payment deleted successfully');
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }

  static Future<bool> checkIfPaymentExists({
    required String studentId,
    required String groupId,
    required String coursId,
  }) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('student.id', isEqualTo: studentId)
          .where('groupe.id', isEqualTo: groupId)
          .where('cours.id', isEqualTo: coursId)
          .get();

      // Check if any document exists in the query result
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking payment existence: $e');
      return false; // Return false on error to avoid blocking logic
    }
  }
}
