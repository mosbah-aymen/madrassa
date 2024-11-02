class Room {
  String id;
  String name;
  DateTime createdAt;
  int floor;
  int tableNumber;
  int chairNumber;

  Room({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.floor,
    required this.tableNumber,
    required this.chairNumber,
  });

  // Convert a Room object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor': floor,
      'createdAt': createdAt.toIso8601String(),
      'tableNumber': tableNumber,
      'chairNumber': chairNumber,
    };
  }

  // Create a Room object from a JSON map.
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      floor: json['floor'],
      createdAt: DateTime.parse(json['createdAt']),
      tableNumber: json['tableNumber'],
      chairNumber: json['chairNumber'],
    );
  }
}
