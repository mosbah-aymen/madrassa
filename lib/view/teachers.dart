import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  Random rand = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les ensaignants'),
      ),
      body: ListView.builder(
          itemCount: 20,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Container(
                  height: 42,
                  width: 42,
                  padding: const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.primaries.elementAt(rand.nextInt(9)).withOpacity(0.15),
                  ),
                  child: Icon(
                    FontAwesomeIcons.personChalkboard,
                    color: primaryColor,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
