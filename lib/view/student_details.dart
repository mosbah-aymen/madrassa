import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/student.dart';

class StudentDetails extends StatelessWidget {
  final Student student;

  const StudentDetails({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails de l'étudiant",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: student.imageUrl.isNotEmpty ? NetworkImage(student.imageUrl) : const AssetImage("assets/images/profile.png") as ImageProvider,
                    ),
                  ),
                  Text(
                    '${student.nom} ${student.prenom}\n${student.nomArab} ${student.prenomArab}',
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
                value: student.email,
              ),
              _buildDetailTile(
                icon: Icons.phone,
                title: 'Téléphone 1',
                value: "${student.phone1}${student.phone1 == student.phone2 ? '' : "\n${student.phone2}"}",
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailTile(
                      icon: Icons.person,
                      title: 'Sexe',
                      value: student.sex.name,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailTile(
                      icon: Icons.home,
                      title: 'Adresse',
                      value: student.address,
                    ),
                  ),
                ],
              ),
              Divider(color: primaryColor),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      selectCours(context);
                    },
                    child: const Text("Nouveau Cours"),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Présence"),
                  )),
                ],
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

  void selectCours(BuildContext context) {
    List<Cours> cours = existingCours;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  title: const Text("Selectionner un cours"),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(cours.length, (index){
                          return ExpansionTile(
                            leading: Container(
                              height: 22,
                              width: 22,
                              padding: const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            title: Text(cours[index].name),
                            children: [
                              GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,

                              ),
                                itemCount: cours[index].groups.length,
                                itemBuilder: (context,i){
                                return SelectableText(cours[index].groups[i].name);
                                },
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ));
            }
          );
        });
  }
}
