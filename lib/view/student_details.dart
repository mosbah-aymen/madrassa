import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/student_attendance.dart';
import 'package:madrassa/view/payment_form.dart';
import 'package:madrassa/view/payment_history_student.dart';

class StudentDetails extends StatefulWidget {
  final Student student;

  const StudentDetails({super.key, required this.student});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  List<Group> groups = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails de l'étudiant",
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentHistoryStudent(student: widget.student)));
          }, icon: const Icon(Icons.history))
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentForm(student: widget.student)));
                setState(() {});
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(secondaryColor),
              ),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ),
                  Text("Payment"),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await presence();
                setState(() {});
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green.shade700),
              ),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.add),
                  ),
                  Text("Présence"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.student.imageUrl.isNotEmpty ? NetworkImage(widget.student.imageUrl) : const AssetImage("assets/images/profile.png") as ImageProvider,
                    ),
                  ),
                  Text(
                    '${widget.student.nom} ${widget.student.prenom}\n${widget.student.nomArab} ${widget.student.prenomArab}',
                    maxLines: 4,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              _buildDetailTile(
                icon: Icons.email,
                title: 'Email',
                value: widget.student.email,
              ),
              _buildDetailTile(
                icon: Icons.phone,
                title: 'Téléphone 1',
                value: "${widget.student.phone1}${widget.student.phone1 == widget.student.phone2 ? '' : "\n${widget.student.phone2}"}",
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailTile(
                      icon: Icons.person,
                      title: 'Sexe',
                      value: widget.student.sex.name,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailTile(
                      icon: Icons.home,
                      title: 'Adresse',
                      value: widget.student.address,
                    ),
                  ),
                ],
              ),
              Divider(color: primaryColor),
              const Text(
                "Les Séances",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FutureBuilder<List<Group>>(
                future: GroupController.getAllGroupsOfStudent(widget.student),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text("Erreur de chargement des données.");
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Aucune donnée disponible.");
                  }

                  groups = snapshot.data!.where((test)=>test.groupeAttendance.length% test.cours!.nombreSeance<test.cours!.nombreSeance).toList();

                  return Column(
                    children: List.generate(
                      groups.length,
                      (groupIndex) {
                        Group group = groups[groupIndex];
                        return Card(
                          color: secondaryColor,
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            collapsedBackgroundColor: Colors.transparent,
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            title: Text(
                              "${group.name}: ${group.cours?.name}",
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            children: [
                              ...List.generate(group.groupeAttendance.length, (month)=> Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ExpansionTile(title: Text("Mois: ${month+1}",style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
                                  iconColor: Colors.white,
                                  collapsedIconColor: Colors.white,
                                  children: List.generate(
                                    group.groupeAttendance.length,
                                        (seanceIndex) {
                                      GroupeAttendance seance = group.groupeAttendance[month][seanceIndex];
                                      StudentAttendance studentAttendance = seance.studentAttendances.firstWhere(
                                            (test) => test.student.id == widget.student.id,
                                      );
                                      return ListTile(
                                        title: Text(
                                          'Le ${'${intl.DateFormat.yMMMMEEEEd('fr').format(seance.date)}\ná ${intl.DateFormat.Hm('fr').format(seance.date)}'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.circle,
                                          color: studentAttendance.status == AttendanceStatus.late
                                              ? Colors.yellowAccent
                                              : studentAttendance.status == AttendanceStatus.absent
                                              ? Colors.redAccent
                                              : Colors.lightGreenAccent,
                                        ),
                                        trailing: Text(
                                          studentAttendance.remarks.isNotEmpty?studentAttendance.remarks:studentAttendance.status.name,
                                          style: TextStyle(
                                            color: studentAttendance.remarks.isNotEmpty?
                                            Colors.orange
                                                :studentAttendance.status == AttendanceStatus.late
                                                ? Colors.yellowAccent
                                                : studentAttendance.status == AttendanceStatus.absent
                                                ? Colors.redAccent
                                                : Colors.lightGreenAccent,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                ),
                              )
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

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.fade,
      ),
      subtitle: Text(
        value.isEmpty ? "N/A" : value,
        style: TextStyle(
          color: primaryColor,
          fontSize: 14,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4),
    );
  }

  Future presence() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Sélectionner le groupe:"),
            content: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  groups.length,
                  (seanceIndex) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black, width: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onTap: () {
                        // Show confirmation dialog on tap
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirmation"),
                              content: Text(
                                "Êtes-vous sûr de vouloir sélectionner ce groupe:\n ${groups[seanceIndex].cours?.name ?? ""}\n ${groups[seanceIndex].name}",
                                textDirection: TextDirection.rtl,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Close the confirmation dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if(groups[seanceIndex].groupeAttendance.isEmpty){
                                      groups[seanceIndex].groupeAttendance.add([]);
                                    }
                                    if (groups[seanceIndex].groupeAttendance.last.isEmpty) {
                                      GroupeAttendance newSession = GroupeAttendance(
                                        date: DateTime.now(),
                                        createdBy: currentAdmin,
                                        studentAttendances: List.generate(
                                            groups[seanceIndex].students.length,
                                            (stIndex) => StudentAttendance(
                                                  id: '',
                                                  date: DateTime.now(),
                                                  student: groups[seanceIndex].students[stIndex],
                                                  status: groups[seanceIndex].students[stIndex].id == widget.student.id ? AttendanceStatus.present : AttendanceStatus.absent,
                                                  createdBy: currentAdmin,
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  remarks: '',
                                                )),
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        id: '',
                                      );
                                      groups[seanceIndex].groupeAttendance.last.add(newSession);
                                    } else {
                                      groups[seanceIndex].groupeAttendance.last.sort((a, b) => a.date.compareTo(b.date));
                                      int x = groups[seanceIndex].groupeAttendance.last.last.studentAttendances.indexWhere((test) => test.student.id == widget.student.id);
                                      if (x >= 0) {
                                        groups[seanceIndex].groupeAttendance.last.last.studentAttendances[x].status = AttendanceStatus.present;
                                        groups[seanceIndex].groupeAttendance.last.last.studentAttendances[x].remarks = '';
                                        groups[seanceIndex].groupeAttendance.last.last.studentAttendances[x].updatedAt = DateTime.now();
                                        groups[seanceIndex].groupeAttendance.last.last.studentAttendances[x].createdAt = DateTime.now();
                                        groups[seanceIndex].groupeAttendance.last.last.studentAttendances[x].createdBy = currentAdmin;
                                      }
                                    }
                                    await GroupController.updateGroup(groups[seanceIndex]).then((v) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text("Confirmer"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      title: Text(
                        groups[seanceIndex].cours?.name ?? "",
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(groups[seanceIndex].name),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
