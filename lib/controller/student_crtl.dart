import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:madrassa/model/student.dart';
import 'package:path_provider/path_provider.dart';

class StudentController {
  static final CollectionReference _studentsCollection =
  FirebaseFirestore.instance.collection('students');
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new student
  static Future<void> createStudent(Student student, File? imageFile) async {
    if (imageFile != null) {
      String imageUrl = await uploadImage(student.id, imageFile);
      student = Student(
        id: student.id,
        nom: student.nom,
        prenom: student.prenom,
        nomArab: student.nomArab,
        prenomArab: student.prenomArab,
        groups: student.groups, // Updated to List<Group>
        email: student.email,
        phone1: student.phone1,
        phone2: student.phone2,
        sex: student.sex,
        address: student.address,
        imageUrl: imageUrl,
        imageBase64: "",
        birthDate: student.birthDate,
        fathersWork: student.fathersWork,
        mothersWork: student.mothersWork,
      );
    }
    await _studentsCollection.add(student.toMap()).then((doc) async {
      doc.update({
        'id': doc.id,
      });
    });
  }

  // Get a single student by ID
  static Future<Student?> getStudentById(String id) async {
    DocumentSnapshot doc = await _studentsCollection.doc(id).get();
    if (doc.exists) {
      return Student.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all students
  Future<List<Student>> getAllStudents() async {
    QuerySnapshot querySnapshot = await _studentsCollection.get();
    return querySnapshot.docs
        .map((doc) => Student.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a student
  static Future<void> updateStudent(Student student, File? imageFile) async {
    if (imageFile != null) {
      // Delete old image if exists
      if (student.imageUrl.isNotEmpty) {
        await _deleteImage(student.id);
      }
      // Upload new image
      String imageUrl = await uploadImage(student.id, imageFile);
      student = Student(
        id: student.id,
        nom: student.nom,
        prenom: student.prenom,
        nomArab: student.nomArab,
        prenomArab: student.prenomArab,
        groups: student.groups, // Updated to List<Group>
        email: student.email,
        phone1: student.phone1,
        phone2: student.phone2,
        sex: student.sex,
        address: student.address,
        imageUrl: imageUrl,
        imageBase64: "",
        birthDate: student.birthDate,
        fathersWork: student.fathersWork,
        mothersWork: student.mothersWork,
      );
    }
    await _studentsCollection.doc(student.id).update(student.toMap());
  }

  // Delete a student and their associated image
  static Future<void> deleteStudent(String id) async {
    Student? student = await getStudentById(id);
    if (student != null && student.imageUrl.isNotEmpty) {
      await _deleteImage(id);
    }
    await _studentsCollection.doc(id).delete();
  }

  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Flag to decide storage method
  static bool useFirebase = true; // Change to false for local storage

  // Upload image to Firebase Realtime Database or Local Folder
  static Future<String> uploadImage(String studentId, File imageFile) async {
    if (useFirebase) {
      // Save file locally first
      final directory = await getApplicationDocumentsDirectory();
      final localPath = "${directory.path}/student_images/$studentId.jpg";
      await Directory("${directory.path}/student_images").create(recursive: true);
      await imageFile.copy(localPath);

      // Save the local path to Realtime Database
      await _dbRef.child('students/$studentId').update({
        'imagePath': localPath,
      });

      return localPath;
    } else {
      // Save file locally without involving the database
      final directory = await getApplicationDocumentsDirectory();
      final localPath = "${directory.path}/student_images/$studentId.jpg";
      await Directory("${directory.path}/student_images").create(recursive: true);
      await imageFile.copy(localPath);
      return localPath;
    }
  }

  // Delete image from Firebase Realtime Database or Local Folder
  static Future<void> _deleteImage(String studentId) async {
    if (useFirebase) {
      // Retrieve the image path from Realtime Database
      final DataSnapshot snapshot = await _dbRef.child('students/$studentId/imagePath').get();

      if (snapshot.exists) {
        final String imagePath = snapshot.value as String;

        // Delete the local file
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Remove the imagePath from the database
        await _dbRef.child('students/$studentId/imagePath').remove();
      }
    } else {
      // Only delete the local file
      final directory = await getApplicationDocumentsDirectory();
      final localPath = "${directory.path}/student_images/$studentId.jpg";

      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
