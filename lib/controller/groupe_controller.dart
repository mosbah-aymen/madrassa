import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/groupe.dart';

class GroupController {
  static final CollectionReference _groupsCollection =
  FirebaseFirestore.instance.collection('groups');

  // Create a new Group
  static Future<void> createGroup(Group group) async {
    await _groupsCollection.add(group.toMap()).then((doc) async {
      await doc.update({'id': doc.id});
    });
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
}
