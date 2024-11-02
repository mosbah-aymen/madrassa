import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:madrassa/model/teacher.dart';

class TeacherController {
  static final CollectionReference _teachersCollection = FirebaseFirestore.instance.collection('teachers');

  // Add a new teacher
  static Future<void> addTeacher(Teacher teacher) async {
    try {
      await _teachersCollection.add(teacher.toMap()).then((d){
        d.update({
          "id":d.id,
        });
      });
    } catch (e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Update an existing teacher
 static Future<void> updateTeacher(Teacher teacher) async {
    try {
      await _teachersCollection.doc(teacher.id).update(teacher.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      } }
  }

  // Delete a teacher
  static Future<void> deleteTeacher(String teacherId) async {
    try {
      await _teachersCollection.doc(teacherId).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      } }
  }

  // Get a teacher by ID
  static Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      DocumentSnapshot doc = await _teachersCollection.doc(teacherId).get();
      if (doc.exists) {
        return Teacher.fromMap(doc.data() as Map<String, dynamic>,);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      } }
    return null;
  }

  // Get all teachers
  static Future<List<Teacher>> getAllTeachers() async {
    try {
      QuerySnapshot querySnapshot = await _teachersCollection.get();
      return querySnapshot.docs.map((doc) {
        return Teacher.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  // Get all teachers Stream
  static Stream<List<Teacher>> getAllTeachersStream(){
      Stream<QuerySnapshot<Object?>> querySnapshot = _teachersCollection.snapshots();
      return querySnapshot.map((snapshot) {
        return snapshot.docs.map((doc) {
          return Teacher.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      });

  }

  // Add or update teacher's profile image
  static Future<void> addOrUpdateProfileImage(String teacherId, String imageUrl) async {
    try {
      await _teachersCollection.doc(teacherId).update({'profileImageUrl': imageUrl});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }  }
  }

  // Delete teacher's profile image
  static Future<void> deleteProfileImage(String teacherId) async {
    try {
      await _teachersCollection.doc(teacherId).update({'profileImageUrl': FieldValue.delete()});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
