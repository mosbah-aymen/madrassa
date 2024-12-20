import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/teacher.dart';

class CoursController {
  static final CollectionReference _coursCollection =
  FirebaseFirestore.instance.collection('cours');

  // Create a new Cours
  static Future<void> createCours(Cours cours) async {
    await _coursCollection.add(cours.toMap()).then((doc) async {
      await doc.update({'id': doc.id});
      for (var value in cours.groups) {
        value.cours!.id=doc.id;
        GroupController.updateGroup(value);
      }
    });

  }

  // Get a single Cours by ID
  static Future<Cours?> getCoursById(String id) async {
    DocumentSnapshot doc = await _coursCollection.doc(id).get();
    if (doc.exists) {
      return Cours.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all Cours
  static Future<List<Cours>> getAllCours() async {
    QuerySnapshot querySnapshot = await _coursCollection.get();
    return querySnapshot.docs
        .map((doc) => Cours.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a Cours
  static Future<void> updateCours(Cours cours) async {
    await _coursCollection.doc(cours.id).update(cours.toMap());
  }

  // Delete a Cours
  static Future<void> deleteCours(String id) async {
    await _coursCollection.doc(id).delete();
  }

  static Future<List<Cours>> getAllCoursOfTeacher(Teacher teacher)async {
    QuerySnapshot querySnapshot = await _coursCollection.get();
    return querySnapshot.docs
        .map((doc) => Cours.fromMap(doc.data() as Map<String, dynamic>))
    .where((test)=>test.teacher.id==teacher.id)
        .toList();

  }
}
