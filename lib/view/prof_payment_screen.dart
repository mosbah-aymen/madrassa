import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/components/stat_card.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/teacher_crtl.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student_attendance.dart';
import 'package:madrassa/model/teacher.dart';
import '../model/groupe.dart';

class ProfPaymentScreen extends StatefulWidget {
  final Teacher teacher;
  final List<Group> allGroups;

  const ProfPaymentScreen({
    super.key,
    required this.teacher,
    required this.allGroups,
  });

  @override
  State<ProfPaymentScreen> createState() => _ProfPaymentScreenState();
}

class _ProfPaymentScreenState extends State<ProfPaymentScreen> {
  List<Group> selectedGroups = [];
  Map<GroupeAttendance, List<StudentAttendance>> selectedStudentAttendances = {};

  int month = 0;

  @override
  void initState() {
    super.initState();
    selectedGroups = List.from(widget.allGroups);
    for (var group in selectedGroups) {
      for (var seance in group.groupeAttendance.last) {
        selectedStudentAttendances[seance] = List.from(seance.studentAttendances);
      }
    }
  }

  List<double> calculateProfPaymentPerGroup() {
    return selectedGroups.map((group) {
      double groupPayment = 0.0;
      for (var seance in group.groupeAttendance) {
        if (selectedStudentAttendances.containsKey(seance)) {
          int presentStudents = selectedStudentAttendances[seance]!.where((studentAttendance) => studentAttendance.remarks.isEmpty).length;
          groupPayment += group.cours!.totalCostPerSeance * presentStudents * group.profPercent * 0.01;
        }
      }
      return groupPayment;
    }).toList();
  }

  void toggleStudentAttendanceSelection(GroupeAttendance seance, StudentAttendance studentAttendance) {
    setState(() {
      if (selectedStudentAttendances[seance]!.contains(studentAttendance)) {
        selectedStudentAttendances[seance]!.remove(studentAttendance);
      } else {
        selectedStudentAttendances[seance]!.add(studentAttendance);
      }
    });
  }

  void toggleGroupeAttendanceSelection(GroupeAttendance seance, bool selected) {
    setState(() {
      if (selected) {
        selectedStudentAttendances[seance] = List.from(seance.studentAttendances);
      } else {
        selectedStudentAttendances[seance]!.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profPayments = calculateProfPaymentPerGroup();
    final totalPayment = profPayments.reduce((value, element) => value + element);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: StatCard(
                    value: "${widget.allGroups.first.cours!.price}",
                    title: "Prix de Cours",
                    unit: "DA",
                    color: Colors.green,
                  )),
                  Expanded(child: StatCard(value: "${widget.allGroups.first.cours!.nombreSeance}", title: "Nombre de Séances", unit: "séance/mois", color: Colors.green)),
                ],
              ),
            ),
            ...List.generate(widget.allGroups.length, (groupIndex) {
              final group = widget.allGroups[groupIndex];
              final groupPayment = profPayments[groupIndex];

              return GroupPaymentCard(
                group: group,
                groupPayment: groupPayment,
                selectedStudentAttendances: selectedStudentAttendances,
                onStudentAttendanceToggle: toggleStudentAttendanceSelection,
                onGroupeAttendanceToggle: toggleGroupeAttendanceSelection,
              );
            }),
            TotalWorkSummary(
              totalSeances: selectedStudentAttendances.isEmpty ? 0 : selectedStudentAttendances.values.map((attendances) => attendances.length).reduce((a, b) => a + b),
              totalPayment: totalPayment,
            ),
            ElevatedButton(
              onPressed: () {
                final profPayments = calculateProfPaymentPerGroup();
                final totalPayment = profPayments.reduce((value, element) => value + element);
                TeacherController.printInvoice(widget.teacher, widget.allGroups, profPayments, totalPayment, selectedStudentAttendances.keys.toList());
              },
              child: const Text("Imprimer le Reçu"),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupPaymentCard extends StatefulWidget {
  final Group group;
  final double groupPayment;
  final Map<GroupeAttendance, List<StudentAttendance>> selectedStudentAttendances;
  final void Function(GroupeAttendance, StudentAttendance) onStudentAttendanceToggle;
  final void Function(GroupeAttendance, bool) onGroupeAttendanceToggle;

  const GroupPaymentCard({
    super.key,
    required this.group,
    required this.groupPayment,
    required this.selectedStudentAttendances,
    required this.onStudentAttendanceToggle,
    required this.onGroupeAttendanceToggle,
  });

  @override
  State<GroupPaymentCard> createState() => _GroupPaymentCardState();
}

class _GroupPaymentCardState extends State<GroupPaymentCard> {
  int month = 0;
  @override
  Widget build(BuildContext context) {
    final events = widget.group.schedule.map((schedule) {
      return '${schedule.start.hour}:${schedule.start.minute.toString().padLeft(2, '0')} - ${schedule.end.hour}:${schedule.end.minute.toString().padLeft(2, '0')}';
    }).join('');

    final repeatedDays = widget.group.repeatedDaysOfWeek?.isNotEmpty == true ? "${widget.group.repeatedDaysOfWeek?.first.start.format(context)} - ${widget.group.repeatedDaysOfWeek?.first.end.format(context)}" : '';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: secondaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ExpansionTile(
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                leading: Text(
                  widget.groupPayment.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.group.cours!.subject.name} ${widget.group.cours!.year}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          widget.group.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (widget.group.groupeAttendance.isNotEmpty) selectMonth(widget.group.groupeAttendance.length-1),
                      ],
                    ),
                    Text(
                      "${widget.group.profPercent.toStringAsFixed(0)}%",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                children: widget.group.groupeAttendance[month].map((seance) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      leading: Checkbox(
                        side: const BorderSide(color: Colors.white, width: 2),
                        activeColor: Colors.green,
                        value: widget.selectedStudentAttendances[seance]?.isNotEmpty ?? false,
                        onChanged: (selected) => widget.onGroupeAttendanceToggle(seance, selected ?? false),
                      ),
                      title: Text(
                        'Le ${intl.DateFormat.yMMMMEEEEd('fr').format(seance.date)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        events.isNotEmpty ? events : repeatedDays,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      trailing: Text(
                        "${(widget.group.cours!.totalCostPerSeance * (widget.selectedStudentAttendances[seance]?.where((test) => test.remarks.isEmpty).length ?? 0) * widget.group.profPercent * 0.01).toStringAsFixed(0)} DA",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
                      ),
                      children: seance.studentAttendances.where((test) => test.remarks.isEmpty).map((studentAttendance) {
                        return ListTile(
                          leading: Checkbox(
                            side: const BorderSide(color: Colors.white, width: 2),
                            activeColor: Colors.green,
                            value: widget.selectedStudentAttendances[seance]?.contains(studentAttendance) ?? false,
                            onChanged: (_) => widget.onStudentAttendanceToggle(seance, studentAttendance),
                          ),
                          title: Text(
                            studentAttendance.student.fullNameFR,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            studentAttendance.remarks.isNotEmpty ? studentAttendance.remarks : studentAttendance.status.name,
                            style: TextStyle(
                              color: studentAttendance.remarks.isNotEmpty
                                  ? Colors.orange
                                  : studentAttendance.status == AttendanceStatus.late
                                      ? Colors.yellowAccent
                                      : studentAttendance.status == AttendanceStatus.absent
                                          ? Colors.redAccent
                                          : Colors.lightGreenAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
              const Divider(
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: const Text(
                    "Statistique",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    const Divider(
                      color: Colors.white,
                    ),
                    ListTile(
                      title: const Text(
                        "Nombre Des étudiants",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      trailing: Text(
                        widget.group.students.length.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Nombre Des séances sélectionnées",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      trailing: Text(
                        widget.selectedStudentAttendances.keys.where((seance) => widget.group.groupeAttendance.contains(seance)).length.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Prix étudiant/séance",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      trailing: Text(
                        widget.group.cours!.totalCostPerSeance.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.white,
              ),
              ListTile(
                title: Text(
                  "total prix de ${widget.group.name}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: Text(
                  widget.groupPayment.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectMonth(int initial) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu(
        initialSelection: initial,
          inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              outlineBorder: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
              activeIndicatorBorder: const BorderSide(
                width: 2,
                color: Colors.white,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              suffixIconColor: Colors.white),
          menuStyle: MenuStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ))),
          textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          onSelected: (i) {
            setState(() {
              month = i!;
            });
          },
          dropdownMenuEntries: List.generate(widget.group.groupeAttendance.length, (index) {
            return DropdownMenuEntry(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
              ),
              value: index,
              label: "Mois ${index + 1}",
            );
          })),
    );
  }
}

class TotalWorkSummary extends StatelessWidget {
  final int totalSeances;
  final double totalPayment;

  const TotalWorkSummary({
    super.key,
    required this.totalSeances,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Total :',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text(
                  "Total Seances Séléctionnées",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: Text(
                  totalSeances.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              ListTile(
                title: const Text(
                  "Total á payer",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: Text(
                  totalPayment.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
