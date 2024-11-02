import 'package:flutter/material.dart';
import 'package:madrassa/model/groupe.dart';

class AttendanceListPage extends StatelessWidget {
  final Group group;

  const AttendanceListPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste de présence: ${group.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: group.students.length, // Replace with actual attendance data
          itemBuilder: (context, index) {
            final student = group.students[index];
            // Replace with actual attendance record
            const isPresent = true;

            return ListTile(
              title: Text(student.nom),
              subtitle: Text('ID: ${student.id}'),
              trailing: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? Colors.green : Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}
