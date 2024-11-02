import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/model/subject.dart';

class SubjectController {
  static final CollectionReference _subjectsCollection =
  FirebaseFirestore.instance.collection('subjects');

  // Create a new Subject
  static Future<Subject> createSubject(Subject subject) async {
    await _subjectsCollection.add(subject.toMap()).then((doc) async {
      await doc.update({'id': doc.id});
      subject = Subject(id: doc.id, name: subject.name);
    });
    return subject;
  }

  // Get a single Subject by ID
  static Future<Subject?> getSubjectById(String id) async {
    DocumentSnapshot doc = await _subjectsCollection.doc(id).get();
    if (doc.exists) {
      return Subject.fromMap(doc.data() as Map<String, dynamic>, );
    }
    return null;
  }

  // Get all Subjects
  static Future<List<Subject>> getAllSubjects() async {
    QuerySnapshot querySnapshot = await _subjectsCollection.get();
    return querySnapshot.docs
        .map((doc) => Subject.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
// Get all Subjects stream
  static Stream<List<Subject>> getAllSubjectsStream() {
    Stream<QuerySnapshot<Object?>> querySnapshot = _subjectsCollection.snapshots();
    return querySnapshot.map((snapshot) {
      return snapshot.docs.map((doc) {
        return Subject.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update a Subject
  static Future<void> updateSubject(Subject subject) async {
    await _subjectsCollection.doc(subject.id).update(subject.toMap());
  }

  // Delete a Subject
  static Future<void> deleteSubject(String id) async {
    await _subjectsCollection.doc(id).delete();
  }
}
