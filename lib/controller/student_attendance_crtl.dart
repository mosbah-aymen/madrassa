import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/student_attendance.dart';

class StudentAttendanceController {
  final CollectionReference studentAttendanceCollection =
  FirebaseFirestore.instance.collection('student_attendance');

  // Add a new StudentAttendance record
  Future<void> addStudentAttendance(StudentAttendance attendance) async {
    try {
      await studentAttendanceCollection.add(attendance.toMap()).then((doc) async {
        await doc.update({'id': doc.id});
      });
      print("StudentAttendance added successfully.");
    } catch (e) {
      print("Failed to add StudentAttendance: $e");
    }
  }

  // Update an existing StudentAttendance record by document ID
  Future<void> updateStudentAttendance(String id, StudentAttendance attendance) async {
    try {
      await studentAttendanceCollection.doc(id).update(attendance.toMap());
      print("StudentAttendance updated successfully.");
    } catch (e) {
      print("Failed to update StudentAttendance: $e");
    }
  }

  // Delete a StudentAttendance record by document ID
  Future<void> deleteStudentAttendance(String id) async {
    try {
      await studentAttendanceCollection.doc(id).delete();
      print("StudentAttendance deleted successfully.");
    } catch (e) {
      print("Failed to delete StudentAttendance: $e");
    }
  }

  // Fetch a single StudentAttendance record by document ID
  Future<StudentAttendance?> getStudentAttendanceById(String id) async {
    try {
      DocumentSnapshot doc = await studentAttendanceCollection.doc(id).get();
      if (doc.exists) {
        return StudentAttendance.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("No StudentAttendance found with ID $id.");
        return null;
      }
    } catch (e) {
      print("Failed to fetch StudentAttendance: $e");
      return null;
    }
  }

  // Fetch all StudentAttendance records for a specific student
  Future<List<StudentAttendance>> getAttendanceForStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await studentAttendanceCollection
          .where('student.id', isEqualTo: studentId)
          .get();
      return querySnapshot.docs
          .map((doc) => StudentAttendance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Failed to fetch attendance for student $studentId: $e");
      return [];
    }
  }

  // Fetch all StudentAttendance records for a specific date
  Future<List<StudentAttendance>> getAttendanceForDate(DateTime date) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];
      QuerySnapshot querySnapshot = await studentAttendanceCollection
          .where('date', isEqualTo: formattedDate)
          .get();
      return querySnapshot.docs
          .map((doc) => StudentAttendance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Failed to fetch attendance for date $date: $e");
      return [];
    }
  }
}
