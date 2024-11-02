import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/teacher.dart';
import 'package:madrassa/view/teacher_details.dart';

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  Random rand = Random();
  List<Teacher> teachers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("teachers").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                teachers.clear();
                for (var value in snapshot.data!.docs) {
                  teachers.add(Teacher.fromMap(value.data(),));
                }
                existingTeachers = teachers;
                return ListView.builder(
                    itemCount: teachers.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeacherDetails(
                                  teacher: teachers[index],
                                ),
                              ),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          tileColor: Colors.primaries.elementAt(6 + rand.nextInt(3)).withOpacity(
                                0.15,
                              ),
                          leading: Container(
                            height: 42,
                            width: 42,
                            padding: const EdgeInsets.only(
                              left: 3,
                              right: 3,
                              top: 3,
                              bottom: 0.5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Icon(
                              FontAwesomeIcons.personChalkboard,
                              color: primaryColor,
                            ),
                          ),
                          title: Text(teachers[index].name),
                          subtitle: Text(
                            "${teachers[index].subject.name} : ${teachers[index].level.name}",
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: primaryColor,
                          ),
                        ),
                      );
                    });
              }
            }
          }),
    );
  }
}
