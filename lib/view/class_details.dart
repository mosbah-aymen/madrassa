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
            // Course Information
            Text('Course: ${cours.name}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Subject: ${cours.subject.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Level: ${cours.level}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Year: ${cours.year}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Created At: ${cours.createdAt}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Teacher: ${cours.teacher.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),

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
                  trailing: IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: () {
                      // Show group details in a dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Group Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Course: ${group.cours?.name ?? 'No course assigned'}', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Room: ${group.room?.name ?? 'No room assigned'}', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Schedule:', style: TextStyle(fontSize: 18)),
                              for (var range in group.schedule)
                                Text('${range.start} - ${range.end}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 16),
                              Text('Students:', style: TextStyle(fontSize: 18)),
                              for (var student in group.students)
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(student.imageUrl),
                                  ),
                                  title: Text('${student.nom} ${student.prenom}'),
                                  subtitle: Text(student.email),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssignStudentPage(cours: cours, group: group),
                                  ),
                                );
                              },
                              child: Text('Assign New Student'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceListPage(cours: cours),
                                  ),
                                );
                              },
                              child: Text('View Attendance'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )).toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignStudentPage(cours: cours, group: cours.groups.isNotEmpty ? cours.groups[0] : null),
                        ),
                      );
                    },
                    child: Text('Assign New Students'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceListPage(cours: cours),
                        ),
                      );
                    },
                    child: Text('View Attendance'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AssignStudentPage extends StatelessWidget {
  final Cours cours;
  final Group? group;

  const AssignStudentPage({super.key, required this.cours, this.group});

  @override
  Widget build(BuildContext context) {
    // Replace this with actual data fetching logic
    final List<Student> allStudents = existingStudents; // Fetch students from Firestore or other sources

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Student to Course ${cours.name}'),
      ),
      body: ListView.builder(
        itemCount: allStudents.length,
        itemBuilder: (context, index) {
          final student = allStudents[index];
          return ListTile(
            leading: Container(
              height: 42,
              width: 42,
              padding: const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: allStudents[index].sex==Sex.male?primaryColor :thirdColor,
              ),
              child: const Icon(
                FontAwesomeIcons.userGraduate,
                color: Colors.white,
              ),
            ),
            title: Text('${student.nom} ${student.prenom}'),
            subtitle: Text(student.email),
            onTap: () {
              if (group != null && !group!.students.contains(student)) {
                group!.students.add(student);
                GroupController.updateGroup(group!);
              }
            },
          );
        },
      ),
    );
  }
}

class AttendanceListPage extends StatelessWidget {
  final Cours cours;

  const AttendanceListPage({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    // Replace this with actual data fetching logic
    final List<StudentAttendance> attendanceList = []; // Fetch attendance data from Firestore or other sources

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${cours.name}'),
      ),
      body: ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          return ListTile(
            title: Text(attendance.student.nom), // Fetch student name using the studentId
            subtitle: Text('Date: ${attendance.date}'),
            trailing: Text(attendance.status.name),
          );
        },
      ),
    );
  }
}
