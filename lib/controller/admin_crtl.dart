import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/admin.dart';

class AdminController {
  final CollectionReference _adminsCollection =
  FirebaseFirestore.instance.collection('admins');

  // Create a new admin
  Future<void> createAdmin(Admin admin) async {
    await _adminsCollection.add(admin.toMap()).then((doc)async{
      await doc.update({
        "id":doc.id,
      });
    });
  }

  // Get a single admin by ID
  Future<Admin?> getAdminById(String id) async {
    DocumentSnapshot doc = await _adminsCollection.doc(id).get();
    if (doc.exists) {
      return Admin.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all admins
  Future<List<Admin>> getAllAdmins() async {
    QuerySnapshot querySnapshot = await _adminsCollection.get();
    return querySnapshot.docs
        .map((doc) => Admin.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update an admin
  Future<void> updateAdmin(Admin admin) async {
    await _adminsCollection.doc(admin.id).update(admin.toMap());
  }

  // Delete an admin
  Future<void> deleteAdmin(String id) async {
    await _adminsCollection.doc(id).delete();
  }
}
