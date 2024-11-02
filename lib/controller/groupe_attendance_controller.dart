import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/groupe_attendance.dart';

class GroupeAttendanceController {
  final CollectionReference groupeAttendanceCollection =
  FirebaseFirestore.instance.collection('groupe_attendance');

  // Add a new GroupeAttendance record
  Future<void> addGroupeAttendance(GroupeAttendance attendance) async {
    try {
      await groupeAttendanceCollection.add(attendance.toMap()).then((doc)async{
        await doc.update({
          "id":doc.id,
        });
      });
      print("GroupeAttendance added successfully.");
    } catch (e) {
      print("Failed to add GroupeAttendance: $e");
    }
  }

  // Update an existing GroupeAttendance record by document ID
  Future<void> updateGroupeAttendance(String id, GroupeAttendance attendance) async {
    try {
      await groupeAttendanceCollection.doc(id).update(attendance.toMap());
      print("GroupeAttendance updated successfully.");
    } catch (e) {
      print("Failed to update GroupeAttendance: $e");
    }
  }

  // Delete a GroupeAttendance record by document ID
  Future<void> deleteGroupeAttendance(String id) async {
    try {
      await groupeAttendanceCollection.doc(id).delete();
      print("GroupeAttendance deleted successfully.");
    } catch (e) {
      print("Failed to delete GroupeAttendance: $e");
    }
  }

  // Fetch a single GroupeAttendance record by document ID
  Future<GroupeAttendance?> getGroupeAttendanceById(String id) async {
    try {
      DocumentSnapshot doc = await groupeAttendanceCollection.doc(id).get();
      if (doc.exists) {
        return GroupeAttendance.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("No GroupeAttendance found with ID $id.");
        return null;
      }
    } catch (e) {
      print("Failed to fetch GroupeAttendance: $e");
      return null;
    }
  }

  // Fetch all GroupeAttendance records for a specific group on a specific date
  Future<List<GroupeAttendance>> getGroupeAttendanceForDate(String groupName, DateTime date) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];
      QuerySnapshot querySnapshot = await groupeAttendanceCollection
          .where('groupName', isEqualTo: groupName)
          .where('date', isEqualTo: formattedDate)
          .get();
      return querySnapshot.docs
          .map((doc) => GroupeAttendance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Failed to fetch attendance for group $groupName on $date: $e");
      return [];
    }
  }

  // Fetch all GroupeAttendance records for a specific group
  Future<List<GroupeAttendance>> getGroupeAttendanceForGroup(String groupName) async {
    try {
      QuerySnapshot querySnapshot = await groupeAttendanceCollection
          .where('groupName', isEqualTo: groupName)
          .get();
      return querySnapshot.docs
          .map((doc) => GroupeAttendance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Failed to fetch attendance for group $groupName: $e");
      return [];
    }
  }
}
