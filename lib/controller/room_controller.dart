import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/model/room.dart';

class RoomController {
  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  static final CollectionReference _roomsCollection = _firestore.collection('rooms');

  // Add a new Room
  static Future<void> addRoom(Room room) async {
    try {
      await _roomsCollection.add(room.toJson()).then((doc)async{
        await doc.update({
          "id":doc.id,
        });
      });
    } catch (e) {
      debugPrint('Error adding room: $e');
      rethrow;
    }
  }
// Add multiple rooms with sequential names
  static Future<void> addMultipleRooms(int roomNumber) async {
    try {
      for (int i = 1; i <= roomNumber; i++) {
        String roomName = 'salle ${i.toString().padLeft(2, '0')}';
        Room room = Room(
          id: "",
          name: roomName,
          floor: 1,
          createdAt: DateTime.now(),
          tableNumber: 0, // Random value for example
          chairNumber:0, // Random value for example
        );
        await addRoom(room);
      }
    } catch (e) {
      debugPrint('Error adding multiple rooms: $e');
      rethrow;
    }
  }
  // Update an existing Room
  static Future<void> updateRoom(Room room) async {
    try {
      await _roomsCollection.doc(room.id).update(room.toJson());
    } catch (e) {
      debugPrint('Error updating room: $e');
      rethrow;
    }
  }

  // Delete a Room by id
  static Future<void> deleteRoom(String roomId) async {
    try {
      await _roomsCollection.doc(roomId).delete();
    } catch (e) {
      debugPrint('Error deleting room: $e');
      rethrow;
    }
  }

  // Get a Room by id
  static Future<Room?> getRoom(String roomId) async {
    try {
      DocumentSnapshot doc = await _roomsCollection.doc(roomId).get();
      if (doc.exists) {
        return Room.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting room: $e');
      rethrow;
    }
  }

  // Get all rooms
  static Stream<List<Room>> getAllRoomsSnapshot() {
    return _roomsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Room.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
  static Future<List<Room>> getAllRooms() async {
    try {
      // Get the snapshot of the collection.
      QuerySnapshot snapshot = await _roomsCollection.get();

      // Convert the snapshot to a list of Room objects.
      return snapshot.docs.map((doc) {
        return Room.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Handle any errors here.
      return [];
    }
  }
}
