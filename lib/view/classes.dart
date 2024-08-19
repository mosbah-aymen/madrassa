import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  Random rand = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les cours'),
      ),
      body: ListView.builder(
          itemCount: 20,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: (){},
                leading: Container(
                  height: 42,
                  width: 42,
                  padding: const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.primaries.elementAt(rand.nextInt(9)).withOpacity(0.15),
                  ),
                  child: Icon(
                    FontAwesomeIcons.bookOpenReader,
                    color: primaryColor,
                  ),
                ),
                title: Text("Cours $index"),
                subtitle: const Text("Prof: ................"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            );
          }),
    );
  }
}
