import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/teacher.dart';

class GroupController {
  static final CollectionReference _groupsCollection =
  FirebaseFirestore.instance.collection('groups');

  // Create a new Group
  static Future<String> createGroup(Group group) async {
    String id='';
    await _groupsCollection.add(group.toMap()).then((doc) async {
      id=doc.id;
      await doc.update({'id': doc.id});
    });
    print(id);
    return id;
  }

  // Get a single Group by ID
  static Future<Group?> getGroupById(String id) async {
    DocumentSnapshot doc = await _groupsCollection.doc(id).get();
    if (doc.exists) {
      return Group.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all Groups
  static Future<List<Group>> getAllGroups() async {
    QuerySnapshot querySnapshot = await _groupsCollection.get();
    return querySnapshot.docs
        .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a Group
  static Future<void> updateGroup(Group group) async {
    await _groupsCollection.doc(group.id).update(group.toMap());
  }

  // Delete a Group
  static Future<void> deleteGroup(String id) async {
    await _groupsCollection.doc(id).delete();
  }

  static Future<List<Group>> getAllGroupsOfStudent(Student student) async {
    QuerySnapshot querySnapshot = await _groupsCollection.get();
    return querySnapshot.docs
        .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
        .where((group) => group.students.any((s) => s.id == student.id)) // Checks if the student's ID matches
        .toList();
  }

  static Future<List<Group>> getAllGroupsOfTeacher(Teacher teacher)async {
    QuerySnapshot querySnapshot = await _groupsCollection.get();
    return querySnapshot.docs
        .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
        .where((test)=>test.cours!.teacher.id==teacher.id)
        .toList();
  }

  static Future<List<Group>> getAllGroupsOfCours(Cours cours) async{
    QuerySnapshot querySnapshot = await _groupsCollection.get();
    return querySnapshot.docs
        .map((doc) => Group.fromMap(doc.data() as Map<String, dynamic>))
        .where((test)=>test.cours!.id==cours.id)
        .toList();

  }

}
