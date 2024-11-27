import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/components/groupe_attendance_widget.dart';
import 'package:madrassa/components/stat_card.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/controller/student_crtl.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/student_attendance.dart'; // Assuming you have a Student model defined.

class GroupeDetails extends StatefulWidget {
  final Group group;
  const GroupeDetails({super.key, required this.group});

  @override
  State<GroupeDetails> createState() => _GroupeDetailsState();
}

class _GroupeDetailsState extends State<GroupeDetails> {
  late Group group;
  List<Student> selectedStudents = []; // List to track selected students.

  void getStudents() async {
    existingStudents = await StudentController().getAllStudents();
  }

  @override
  void initState() {
    group = widget.group;
    if (existingStudents.isEmpty) {
      getStudents();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("groups").doc(group.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                group = Group.fromMap(snapshot.data!.data()!);
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: selectStudents, // Call the function here.
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.green),
                            ),
                            child: const Text('Ajouter'),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.orange),
                            ),
                            child: const Text('Modifier'),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.red),
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: StatCard(value: group.students.length.toString(), title: "Nombre des étudiants", unit: "étudiants"),
                    ),
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              value: group.repeatedDaysOfWeek == null ? "0" : group.repeatedDaysOfWeek!.length.toString(),
                              title: "Jours répétés",
                              unit: "jours/semaine",
                            ),
                          ),
                          Expanded(
                            child: StatCard(
                              value: group.schedule.length.toString(),
                              title: "séances programées",
                              unit: "séance",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Text(
                      "Les Séances programées",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...List.generate(group.groupeAttendance.length, (month) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text("Mois : ${month + 1}"),
                          children: [
                            ...List.generate(group.groupeAttendance[month].length, (index) => GroupeAttendanceWidget(attendance: group.groupeAttendance[month][index])),
                          ],
                        ),
                      );
                    }),
                    ElevatedButton(
                        onPressed: () {
                          if (group.groupeAttendance.isEmpty) {
                            // first month
                            group.groupeAttendance.add([]);
                          }
                          if (group.groupeAttendance.last.length < group.cours!.nombreSeance) {
                            createNewSession(group.groupeAttendance.length - 1);
                          } else {
                            newMonth();
                          }
                        },
                        child: const Text('Nouvelle séance'),),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }

  void selectStudents() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select Students"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: existingStudents.length, // Assuming `existingStudents` is a global list.
                itemBuilder: (context, index) {
                  Student student = existingStudents[index];
                  bool isSelected = selectedStudents.contains(student);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text('${student.nom} ${student.prenom}'), // Display student name.
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedStudents.add(student);
                        } else {
                          selectedStudents.remove(student);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ));
                  for (var value in selectedStudents) {
                    if (group.students.indexWhere((t) => t.id == value.id) < 0) {
                      group.students.add(value);
                    }
                  }
                  await GroupController.updateGroup(group).then((v) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                child: const Text("Confirmer"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler"),
              ),
            ],
          );
        });
      },
    );
  }

  void createNewSession(int month) async {
    await showDialog(
      context: context,
      builder: (context) {
        List<StudentAttendance> sessionAttendances = group.students.map((student) {
          return StudentAttendance(
            id: '',
            student: student,
            status: AttendanceStatus.absent,
            createdBy: currentAdmin,
            createdAt: DateTime.now(),
            date: DateTime.now(),
            updatedAt: DateTime.now(),
            remarks: '',
          );
        }).toList();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Nouvelle séance"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessionAttendances.length,
                  itemBuilder: (context, index) {
                    final studentAttendance = sessionAttendances[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(studentAttendance.student.imageUrl),
                            radius: 20,
                          ),
                          title: Text(
                            '${studentAttendance.student.nom} ${studentAttendance.student.prenom}',
                          ),
                          subtitle: DropdownButton<AttendanceStatus>(
                            value: studentAttendance.status,
                            items: AttendanceStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.name),
                              );
                            }).toList(),
                            onChanged: (status) {
                              setState(() {
                                studentAttendance.status = status!;
                              });
                            },
                          ),
                        ),
                        if (studentAttendance.remarks.isNotEmpty)
                          TextFormField(
                            initialValue: studentAttendance.remarks,
                            decoration: const InputDecoration(labelText: 'Remarks'),
                            onChanged: (value) {
                              studentAttendance.remarks = value;
                            },
                          ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Create a new attendance session
                    GroupeAttendance newSession = GroupeAttendance(
                      date: DateTime.now(),
                      createdBy: currentAdmin, // Adjust according to your model
                      studentAttendances: sessionAttendances,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      id: '',
                    );
                    // Update the group with the new session
                    group.groupeAttendance.last.add(newSession);
                    setState(() {});
                    await GroupController.updateGroup(group).then((_) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text("Confirmer"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
              ],
            );
          },
        );
      },
    ).then((e) {
      setState(() {});
    });
  }

  void newMonth() async {
      // Show confirmation dialog in French
      bool confirmNewMonth = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Nouveau Mois?"),
            content: const Text("Le cours pour ce groupe a atteint le nombre maximum de séances. Voulez-vous commencer un nouveau mois ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Confirmer"),
              ),
            ],
          );
        },
      );

      // If the user confirms, add a new month
      if (confirmNewMonth) {
        group.groupeAttendance.add([]);
        await GroupController.updateGroup(group);
        setState(() {});
      }

  }
}
