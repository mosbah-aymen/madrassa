class Subject {
  final String id;
  final String name;

  Subject({
    required this.id,
    required this.name,
  });

  // Convert a Subject to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a Subject from a Map
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'] ?? '',
    );
  }
}
