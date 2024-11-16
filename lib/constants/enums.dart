import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/room.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/subject.dart';
import 'package:madrassa/model/teacher.dart';

enum Role {
  administrateur,
  secretaire,
}

enum Sex {
  male,
  female,
}

enum AttendanceStatus {
  present,
  absent,
  late,
  nonPaye,
}

enum Level {
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


enum PromotionTypeEnum {
  freeEnrollment,
  teacherOnlyPayment,
  customDiscount,
}


List<Cours> existingCours = [];
List<Group> existingGroups = [];
List<Teacher> existingTeachers = [];
List<Student> existingStudents = [];
List<Subject> existingSubjects = [];
List<Room> existingRooms = [];
