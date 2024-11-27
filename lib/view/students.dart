import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/view/student_details.dart';

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  Random rand = Random();
  List<Student> students = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('students').snapshots(),
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
                students.clear();
                for (var value in snapshot.data!.docs) {
                  students.add(Student.fromMap(value.data()));
                }
                existingStudents=students;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: students.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () async{
                             await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetails(
                                    student: students[index],
                                  ),
                                ),
                              );
                             setState(() {});
                            },
                            leading:
                            students[index].imageUrl.isNotEmpty?ClipRRect(
                                 borderRadius: BorderRadius.circular(10),
                                child: Hero(
                                    tag: students[index].id,
                                    child: Image.file(File(students[index].imageUrl),height: 50,width: 50,fit: BoxFit.cover,))):
                            Container(
                              height: 42,
                              width: 42,
                              padding: const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: students[index].sex==Sex.male?primaryColor:thirdColor,
                              ),
                              child:const Icon(
                                FontAwesomeIcons.userGraduate,
                                color: Colors.white,
                              ),
                            ),
                            title: Text("${students[index].nom.toUpperCase()} ${students[index].prenom}"),
                            subtitle: Text("${students[index].nomArab.toUpperCase()} ${students[index].prenomArab}"),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: students[index].sex==Sex.male?primaryColor:thirdColor,
                              size: 15,
                            ),
                          ),
                        );
                      }),
                );
              }
            }
          }),
    );
  }
}
