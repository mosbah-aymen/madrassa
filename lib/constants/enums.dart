import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/room.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/subject.dart';
import 'package:madrassa/model/teacher.dart';

enum Role{ administrateur, secretaire, }
enum Sex{ male, female}
enum AttendanceStatus {
  present,
  absent,
  late,
}
enum Level{
  primaire,
  moyene,
  secondaire,
  university,
  autre,
}
enum AutreLevel {
  preA,
  a1,
  a2,
  a3,
  b1,
  b2,
  c1,
  c2,
}

extension AutreLevelExtension on AutreLevel {
  String get name {
    switch (this) {
      case AutreLevel.preA:
        return "Pré A";
      case AutreLevel.a1:
        return "A1";
      case AutreLevel.a2:
        return "A2";
      case AutreLevel.a3:
        return "A3";
      case AutreLevel.b1:
        return "B1";
      case AutreLevel.b2:
        return "B2";
      case AutreLevel.c1:
        return "C1";
      case AutreLevel.c2:
        return "C2";
    }
  }
}

// enum Subject{
//   math,
//   physique,
//   langueArab,
//   langueFrancaise,
//   langueAnglaise,
//   scienceIslamique,
//   scienceDeLaNatureEtDeVie,
//   histroriqueEtGeografique,
//   philosophy,
//   robotique,
//   sourobane,
//   autre,
// }
// extension SubjectExtension on Subject {
//   String get name {
//     switch (this) {
//       case Subject.math:
//         return 'Mathématiques';
//       case Subject.physique:
//         return 'Physique';
//       case Subject.langueArab:
//         return 'Langue Arabe';
//       case Subject.langueFrancaise:
//         return 'Langue Française';
//       case Subject.langueAnglaise:
//         return 'Langue Anglaise';
//       case Subject.scienceIslamique:
//         return 'Science Islamique';
//       case Subject.scienceDeLaNatureEtDeVie:
//         return 'Science de la Nature et de la Vie';
//       case Subject.histroriqueEtGeografique:
//         return 'Histoire et Géographie';
//       case Subject.philosophy:
//         return 'Philosophie';
//       case Subject.robotique:
//         return 'Robotique';
//       case Subject.sourobane:
//         return 'Sourobane';
//       case Subject.autre:
//         return 'Autre';
//     }
//   }
// }
//

List<Cours> existingCours=[];
List<Group> existingGroups=[];
List<Teacher> existingTeachers=[];
List<Student> existingStudents=[];
List<Subject> existingSubjects=[];
List<Room> existingRooms=[];