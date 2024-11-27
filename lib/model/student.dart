import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/groupe.dart'; // Import the Group model

class Student {
  String id;
  String nom, prenom;
  String nomArab, prenomArab;
  List<Group> groups; // Updated to List<Group>
  String email;
  String phone1, phone2;
  Sex sex;
  String fathersWork;
  String mothersWork;
  String address;
  DateTime birthDate;
  String imageUrl;
  String imageBase64;

  Student({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.nomArab,
    required this.prenomArab,
    required this.groups,
    required this.email,
    required this.phone1,
    required this.phone2,
    required this.sex,
    required this.address,
    required this.imageUrl,
    required this.imageBase64,
    required this.birthDate,
  required this.fathersWork,
  required this.mothersWork,
  });

  factory Student.fromMap(Map<String, dynamic> data) {
    return Student(
      id: data['id'],
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      nomArab: data['nomArab'] ?? '',
      prenomArab: data['prenomArab'] ?? '',
      groups: List.generate(data['groups']==null?0:data['groups'].length, (index)=>Group.fromMap(data['groups'][index])),
      email: data['email'] ?? '',
      phone1: data['phone1'] ?? '',
      phone2: data['phone2'] ?? '',
      sex: data['sex'] == Sex.male.name ? Sex.male : Sex.female,
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageBase64: data['imageBase64'] ?? '',
      birthDate: data['birthDate'].toDate(),
      fathersWork: data['fathersWork'] ?? '',
      mothersWork: data['mothersWork'] ?? '',
    );
  }

  String get fullNameFR => "$nom $prenom";
  String get fullNameAR => "$nomArab $prenomArab";

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'nomArab': nomArab,
      'prenomArab': prenomArab,
      'groups': groups.map((group) => group.toMap()).toList(), // Convert Group to Map
      'email': email,
      'phone1': phone1,
      'phone2': phone2,
      'sex': sex.name,
      'address': address,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'birthDate': birthDate,
      'fathersWork': fathersWork,
      'mothersWork': mothersWork,
    };
  }
}
