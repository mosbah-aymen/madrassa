class SchoolClass {
  String id;
  String name;
  String teacherId;
  List<String> studentIds;

  SchoolClass({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentIds,
  });

  factory SchoolClass.fromMap(Map<String, dynamic> data, String documentId) {
    return SchoolClass(
      id: documentId,
      name: data['name'] ?? '',
      teacherId: data['teacherId'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'studentIds': studentIds,
    };
  }
}
