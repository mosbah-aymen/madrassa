import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // Required for initializing locales
import 'package:madrassa/components/groupe_attendance_widget.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/teacher.dart';
import 'package:madrassa/view/prof_payment_screen.dart';

import '../controller/groupe_controller.dart';

class TeacherDetails extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetails({super.key, required this.teacher});

  @override
  State<TeacherDetails> createState() => _TeacherDetailsState();
}

class _TeacherDetailsState extends State<TeacherDetails> {
  List<Group> groups = [];
  @override
  Widget build(BuildContext context) {
    // Initialize the date formatting for French locale
    initializeDateFormatting('fr', null);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails d'enseignant",
        ),
        actions: [
          IconButton(
              onPressed: () {},
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(secondaryColor)),
              icon: const Icon(
                Icons.call,
                color: Colors.white,
              ))
        ],
      ),
      bottomNavigationBar: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfPaymentScreen(teacher: widget.teacher, allGroups: groups)));
          },
          child: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.teacher.name,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Text(
                        widget.teacher.email,
                        style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "${widget.teacher.subject.name}\n${widget.teacher.level.name}",
                        style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: primaryColor),
              FutureBuilder<List<Group>>(
                future: GroupController.getAllGroupsOfTeacher(widget.teacher),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Erreur de chargement des cours: ${snapshot.error?.toString()}");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucune cours disponible.");
                  }

                  groups = snapshot.data!;
                  return Column(
                    children: List.generate(
                      groups.length,
                      (groupIndex) {
                        Group group = groups[groupIndex];
                        print(group.id);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ExpansionTile(
                            leading: Icon(
                              FontAwesomeIcons.bookOpenReader,
                              color: secondaryColor,
                            ),
                            title: Text(
                              '${group.cours!.name}\n${group.name}',
                              textDirection: TextDirection.rtl, // Align text to the right
                              textAlign: TextAlign.center, // Align text to the left
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              ...List.generate(
                                group.groupeAttendance.length,
                                (month) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ExpansionTile(
                                    title: Text("Mois : ${month + 1}"),
                                    children: [
                                      ...List.generate(
                                        group.groupeAttendance[month].length,
                                        (index) => GroupeAttendanceWidget(
                                          attendance: group.groupeAttendance[month][index],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
