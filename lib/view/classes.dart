import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/view/class_details.dart';
import 'package:madrassa/view/groupe_details.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  Random rand = Random();
  List<Cours> courses = [];
  List<Group> groups =[];
  @override
  void initState(){
    initializeDateFormatting('fr', null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("cours").orderBy("createdAt",descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // Clear previous courses and add the latest data
            courses.clear();
            for (var value in snapshot.data!.docs) {
              Cours cours =Cours.fromMap(value.data());
              courses.add(cours);
            }
            existingCours=courses;
            // Display the courses in a list
            return courses.isEmpty
                ? const Center(
              child: Text("Aucun cours ajouté"),
            )
                : ListView.builder(
              itemCount: courses.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CoursDetailsPage(cours: course,)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      leading: Icon(FontAwesomeIcons.bookOpenReader,color: secondaryColor,),
                      title: Text(
                        course.name,
                        textDirection: TextDirection.rtl, // Align text to the right
                        textAlign: TextAlign.center, // Align text to the left
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true, // Important pour permettre à GridView de s'afficher correctement dans un ExpansionTile
                            physics: const NeverScrollableScrollPhysics(), // Désactive le défilement indépendant du GridView
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Nombre de colonnes dans la grille
                              crossAxisSpacing: 8.0, // Espacement horizontal entre les cartes
                              mainAxisSpacing: 8.0, // Espacement vertical entre les cartes
                              childAspectRatio: 1.5, // Aspect des cartes (1.5 de largeur pour 1 de hauteur)
                            ),
                            itemCount: course.groups.length,
                            itemBuilder: (context, groupIndex) {
                              final group = course.groups[groupIndex];

                              // Format the schedules for each group
                              final events = group.schedule.map((schedule) {
                                return '${intl.DateFormat.MMMMEEEEd("fr").format(schedule.start)}\n${TimeOfDay(hour: schedule.start.hour,minute: schedule.start.minute).format(context)} - ${TimeOfDay(hour: schedule.end.hour,minute: schedule.end.minute).format(context)}';
                              }).join('\n');

                              // Prepare the repeated days information
                              String repeatedDays = "";
                              if (group.repeatedDaysOfWeek != null && group.repeatedDaysOfWeek!.isNotEmpty) {
                                if (group.repeatedDaysOfWeek!.length < 7) {
                                  repeatedDays = group.repeatedDaysOfWeek!.map((day) => day.dayNameFr).join(', ');
                                } else {
                                  repeatedDays = "Chaque jour";
                                }
                                repeatedDays +="\n${group.repeatedDaysOfWeek!.first.start.format(context)} - ${group.repeatedDaysOfWeek!.first.end.format(context)}";
                              }

                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupeDetails(group: group,)));
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 2.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          group.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Salle: ${group.room?.name ?? 'salle non sélectionnée'}',
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                        if (events.isNotEmpty)
                                          Expanded(
                                            child: Text(
                                              events,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                          ),
                                        if (repeatedDays.isNotEmpty)
                                          Expanded(
                                            child: Text(
                                              repeatedDays,
                                              style: const TextStyle(color: Colors.black54),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
