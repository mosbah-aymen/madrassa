class Teacher {
  String id;
  String name;
  String email;
  String phone;
  String subject;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
  });

  factory Teacher.fromMap(Map<String, dynamic> data, String documentId) {
    return Teacher(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      subject: data['subject'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
    };
  }
}
