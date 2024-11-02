
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/components/stat_card.dart';
import 'package:madrassa/model/groupe.dart';

class GroupeDetails extends StatefulWidget {
  final Group group;
  const GroupeDetails({super.key,required this.group});

  @override
  State<GroupeDetails> createState() => _GroupeDetailsState();
}

class _GroupeDetailsState extends State<GroupeDetails> {
  late Group group;
  @override
  void initState() {
    group = widget.group;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.doc("/groups/${group.id}").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()),);
            } else {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                group = Group.fromMap(snapshot.data!.data()!);
                return Column(
              children: [
                SizedBox(
                    height: 100,
                    child: StatCard(value: group.students.length.toString(), title: "Nombre des étudiants", unit: "étudiants")),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(child: StatCard(value:group.repeatedDaysOfWeek ==null?"0": group.repeatedDaysOfWeek!.length.toString(), title: "Jours répétés", unit: "jours/semaine")),
                      Expanded(child: StatCard(value: group.schedule.length.toString(), title: "séances programées", unit: "séance")),
                    ],
                  ),
                ),
                const Divider(),
               Text(group.cours==null?"erreur : nom de cours":group.cours!.name,style: const TextStyle(
                 fontSize: 22,
                 fontWeight: FontWeight.bold,
               ),),
              ],
            );
              }
            }
          }
        ),
      ),
    );
  }
}
