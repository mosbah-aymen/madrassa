import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:madrassa/model/student.dart';

class StudentController {
  static final CollectionReference _studentsCollection =
  FirebaseFirestore.instance.collection('students');
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new student
  static Future<void> createStudent(Student student, File? imageFile) async {
    if (imageFile != null) {
      String imageUrl = await _uploadImage(student.id, imageFile);
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
      String imageUrl = await _uploadImage(student.id, imageFile);
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

  // Upload image to Firebase Storage
  static Future<String> _uploadImage(String studentId, File imageFile) async {
    Reference ref = _storage.ref().child('student_images/$studentId');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  // Delete image from Firebase Storage
  static Future<void> _deleteImage(String studentId) async {
    Reference ref = _storage.ref().child('student_images/$studentId');
    await ref.delete();
  }
}
