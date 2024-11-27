import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/teacher.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TeacherController {
  static final CollectionReference _teachersCollection = FirebaseFirestore.instance.collection('teachers');

  // Add a new teacher
  static Future<void> addTeacher(Teacher teacher) async {
    try {
      await _teachersCollection.add(teacher.toMap()).then((d) {
        d.update({
          "id": d.id,
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Update an existing teacher
  static Future<void> updateTeacher(Teacher teacher) async {
    try {
      await _teachersCollection.doc(teacher.id).update(teacher.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Delete a teacher
  static Future<void> deleteTeacher(String teacherId) async {
    try {
      await _teachersCollection.doc(teacherId).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Get a teacher by ID
  static Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      DocumentSnapshot doc = await _teachersCollection.doc(teacherId).get();
      if (doc.exists) {
        return Teacher.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  // Get all teachers
  static Future<List<Teacher>> getAllTeachers() async {
    try {
      QuerySnapshot querySnapshot = await _teachersCollection.get();
      return querySnapshot.docs.map((doc) {
        return Teacher.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get all teachers Stream
  static Stream<List<Teacher>> getAllTeachersStream() {
    Stream<QuerySnapshot<Object?>> querySnapshot = _teachersCollection.snapshots();
    return querySnapshot.map((snapshot) {
      return snapshot.docs.map((doc) {
        return Teacher.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Add or update teacher's profile image
  static Future<void> addOrUpdateProfileImage(String teacherId, String imageUrl) async {
    try {
      await _teachersCollection.doc(teacherId).update({'profileImageUrl': imageUrl});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Delete teacher's profile image
  static Future<void> deleteProfileImage(String teacherId) async {
    try {
      await _teachersCollection.doc(teacherId).update({'profileImageUrl': FieldValue.delete()});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static void printInvoice(
    Teacher teacher,
    List<Group> allGroups,
    List<double> profPayments,
    double totalPayment,
    List<GroupeAttendance> selectedSeances,
  ) async
  {
    final pdf = pw.Document();
    final dateFormatter = intl.DateFormat.yMMMMEEEEd('fr');
    final arabicFont = await PdfGoogleFonts.amiriRegular();
    int nombreDesEtudiant = 0;
    for (var value in allGroups) {
      nombreDesEtudiant+=value.students.length;
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            "Reçu de Paiement",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Date : ${intl.DateFormat.yMd().format(DateTime.now())}", style: const pw.TextStyle(fontSize: 14)),
              pw.Text(
                teacher.name,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  font: arabicFont,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.Divider(),

          // Iterate over all groups and display payment info for each group
          ...List.generate(allGroups.where((test)=>test.groupeAttendance.isNotEmpty).length, (index) {
            final group = allGroups[index];
            final groupPayment = profPayments[index];

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "${group.cours!.subject.name} - ${group.cours!.year}",
                  style: pw.TextStyle(fontSize: 18, font: arabicFont,fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.Text(group.name, style: pw.TextStyle(fontSize: 14,fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Prix étudiant / séance : ", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("${group.cours!.totalCostPerSeance.toStringAsFixed(1)} DA", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Pourcentage : ", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("${group.profPercent} %", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Prix Enseignant / étudiant : ", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("${group.cours!.totalCostPerSeance*group.profPercent*0.01} DA", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Nombre d'étudiants : ", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("${group.students.length}", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Group Attendance
                pw.Text("Séances :", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Column(
                  children: group.groupeAttendance.last.map((seance) {
                    final isSelected = selectedSeances.indexWhere((test) => test.id == seance.id) >= 0;
                    final events = group.schedule.map((schedule) {
                      return '${schedule.start.hour}:${schedule.start.minute.toString().padLeft(2, '0')} - ${schedule.end.hour}:${schedule.end.minute.toString().padLeft(2, '0')}';
                    }).join('');

                    final repeatedDays = group.repeatedDaysOfWeek?.isNotEmpty == true
                        ? "${group.repeatedDaysOfWeek?.first.start} - ${group.repeatedDaysOfWeek?.first.end}"
                        : '';

                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("${dateFormatter.format(seance.date)}  :  ${events.isNotEmpty ? events : repeatedDays}" ),
                        pw.Text("${isSelected ? (group.cours!.totalCostPerSeance * seance.studentAttendances.length*group.profPercent*0.01).toStringAsFixed(0) : "0"} DA"),
                      ],
                    );
                  }).toList(),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Total pour ${group.name} : ", style: pw.TextStyle(fontSize: 14,fontWeight: pw.FontWeight.bold)),
                    pw.Text("${groupPayment.toStringAsFixed(1)} DA", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.Divider(),
              ],
            );
          }),

          // Summary
          pw.Divider(),
          pw.Column(children: [
            pw.Text("Résumé du Travail", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total Séances Sélectionnées : ", style: const pw.TextStyle(fontSize: 14)),
                pw.Text("${selectedSeances.length}", style: const pw.TextStyle(fontSize: 14)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Nombre Total Des Etudiants : ", style: const pw.TextStyle(fontSize: 14)),
                pw.Text("$nombreDesEtudiant", style: const pw.TextStyle(fontSize: 14)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total à Payer : ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("${totalPayment.toStringAsFixed(1)} DA", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ])
        ],
      ),
    );

    // Display the PDF preview and print options
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
