import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/student_attendance.dart';

class CoursDetailsPage extends StatefulWidget {
  final Cours cours;

  const CoursDetailsPage({super.key, required this.cours});

  @override
  _CoursDetailsPageState createState() => _CoursDetailsPageState();
}

class _CoursDetailsPageState extends State<CoursDetailsPage> {
  late Cours cours;

  @override
  void initState() {
    super.initState();
    cours = widget.cours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cours.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Groups List
            Text('Groups:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Column(
              children: cours.groups.map((group) => Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(group.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Room: ${group.room?.name ?? 'No room assigned'}'),
                      Text('Schedule:'),
                      for (var range in group.schedule)
                        Text('${range.start} - ${range.end}'),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

