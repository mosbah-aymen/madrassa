import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:madrassa/components/stat_card.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/groupe_attendance.dart';

class GroupeAttendanceWidget extends StatelessWidget {
  final GroupeAttendance attendance;

  const GroupeAttendanceWidget({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondaryColor,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            'Le ${'${DateFormat.yMMMMEEEEd('fr').format(attendance.date)}\ná ${DateFormat.Hm('fr').format(attendance.date)}'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          subtitle: Text(
            'Par : ${attendance.createdBy.name}',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic,color: Colors.white),
          ),
          children: [
            const Divider(),
            const Text(
              'Liste De Présence:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendance.studentAttendances.where((test)=>test.remarks.isEmpty).length,
              itemBuilder: (context, studentIndex) {
                final studentAttendance = attendance.studentAttendances.where((test)=>test.remarks.isEmpty).toList()[studentIndex];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child:  Icon(
                      FontAwesomeIcons.graduationCap,
                      color: studentAttendance.student.sex.index == Sex.male.index ? secondaryColor : thirdColor,
                    ),
                  ),
                  title: Text(
                    '${studentAttendance.student.nom} ${studentAttendance.student.prenom}',
                    style: const TextStyle(fontSize: 14,color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        studentAttendance.status.name,
                        style: TextStyle(
                          color: studentAttendance.status.index == AttendanceStatus.late.index
                              ? Colors.yellowAccent
                              : studentAttendance.status.index == AttendanceStatus.absent.index
                                  ? Colors.redAccent
                                  : Colors.lightGreenAccent,
                        ),
                      ),
                      Icon(Icons.circle,color: studentAttendance.status.index == AttendanceStatus.late.index
                          ? Colors.yellowAccent
                          : studentAttendance.status.index == AttendanceStatus.absent.index
                          ? Colors.redAccent
                          : Colors.lightGreenAccent,),
                    ],
                  ),
                  subtitle: (studentAttendance.remarks.isNotEmpty) ? Text('Remarque: ${studentAttendance.remarks}',
                    style: const TextStyle(fontSize: 10,color: Colors.white),
                  ) : null,
                );
              },
            ),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text(
                'Présents: ${attendance.studentAttendances.where((test) => test.status.index == AttendanceStatus.present.index).length}',
                style: const TextStyle(
                  fontSize: 12,color: Colors.white,
                ),
              ),
              Text(
                'Absents: ${attendance.studentAttendances.where((test) => test.status.index == AttendanceStatus.absent.index).length}',
                style: const TextStyle(
                  fontSize: 12,color: Colors.white,
                ),
              ),
              Text(
                'Retards: ${attendance.studentAttendances.where((test) => test.status.index == AttendanceStatus.late.index).length}',
                style: const TextStyle(
                  fontSize: 12,color: Colors.white,
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
