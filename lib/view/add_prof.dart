import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:madrassa/components/build_text_form_field.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/subject_controller.dart';
import 'package:madrassa/controller/teacher_crtl.dart';
import 'package:madrassa/model/subject.dart';
import 'package:madrassa/model/teacher.dart';

class AddProf extends StatefulWidget {
  const AddProf({super.key});

  @override
  State<AddProf> createState() => _AddProfState();
}

class _AddProfState extends State<AddProf> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Level? levelSelected;
  Subject? subjectSelected;
  Sex sexSelected = Sex.male;

  String newSubjectName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un enseignant"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey, // Global key to track form state
            child: Column(
              children: [
                buildTextFormField(
                  nameController,
                  "Nom :",
                  TextInputType.text,
                  isRequired: true,
                ),
                buildTextFormField(
                  emailController,
                  "Email :",
                  TextInputType.emailAddress,
                ),
                buildTextFormField(
                  phoneController,
                  "Téléphone 1 :",
                  TextInputType.phone,
                  isRequired: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: selectLevel()),
                      const SizedBox(width: 10),
                      Expanded(child: selectSex()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: selectSubject(),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Additional validation
                      if (levelSelected == null) {
                        Fluttertoast.showToast(
                          msg: "Vous avez oublié le niveau de l'enseignant",
                          backgroundColor: Colors.red,
                        );
                      } else if (subjectSelected == null) {
                        Fluttertoast.showToast(
                          msg: "Vous avez oublié la matière de l'enseignant",
                          backgroundColor: Colors.red,
                        );
                      } else {
                        // Add teacher logic if form is valid
                        Teacher teacher = Teacher(
                          id: "",
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          subject: subjectSelected!,
                          level: levelSelected!,
                          sex: sexSelected,
                          createdAt: DateTime.now(),
                        );
                        await TeacherController.addTeacher(teacher).then((c) {
                          existingTeachers.add(teacher);
                          Navigator.pop(context);
                        });
                      }
                    } else {
                      // Form is not valid, show error toast
                      Fluttertoast.showToast(
                        msg: "Veuillez corriger les erreurs dans le formulaire",
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget selectLevel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton(
        value: levelSelected,
        borderRadius: BorderRadius.circular(20),
        hint: const Text("Le niveau"),
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        items: List.generate(
          Level.values.length,
              (index) => DropdownMenuItem(
            value: Level.values[index],
            child: Text(Level.values[index].name.toUpperCase()),
          ),
        ),
        style: TextStyle(color: primaryColor,),
        onChanged: (v) {
          levelSelected =v;
          setState(() {});
        },
      ),
    );
  }
  Widget selectSubject() {
    return StreamBuilder<List<Subject>>(
      stream: SubjectController.getAllSubjectsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final List<Subject> subjects = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<Subject>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return subjects;
                }

                final filteredSubjects = subjects.where((Subject subject) {
                  return subject.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                }).toList();

                // Add an option to create a new subject if no matches are found
                if (filteredSubjects.isEmpty) {
                  filteredSubjects.add(
                      Subject(name: textEditingValue.text, id: "")
                  );
                }

                return filteredSubjects;
              },
              displayStringForOption: (Subject subject) => subject.name,
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                  ) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Selectionner une matiere',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.subject_rounded,
                    ),
                    suffixIcon: IconButton(
                      icon: !focusNode.hasFocus
                          ? const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      )
                          : const Icon(
                        Icons.keyboard_arrow_up_rounded,
                      ),
                      onPressed: () {
                        if (!focusNode.hasFocus) {
                          focusNode.requestFocus();
                        } else {
                          focusNode.unfocus();
                        }
                      },
                    ),
                  ),
                  onChanged: (s) {
                    newSubjectName=s;
                  },
                );
              },
              onSelected: (Subject selection) async{
                if (selection.id == "") { // Check for the "Add new" option
                  await SubjectController.createSubject(Subject(name: newSubjectName, id: ""));
                } else {
                  subjectSelected = selection;
                }
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Subject> onSelected, Iterable<Subject> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      color: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Subject subject = options.elementAt(index);
                          return ListTile(
                            onTap: () {
                              onSelected(subject);
                            },
                            leading: Icon(Icons.subject_rounded, color: secondaryColor),
                            title: Text(subject.name),
                            trailing: GestureDetector(
                                onTap: ()async{
                                  await _deleteSubject(subject);
                                },
                                child: const Icon(Icons.remove_circle_outline,color: Colors.red,)),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  Future _deleteSubject(Subject subject) async{
    showDialog(context: context, builder: (context)=> AlertDialog(
      title: const Text("Supprimer une Matiere"),
      content:const Text("Voulez-vous vraiment supprimer cette matiere? ") ,
      actions: [
        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuler")),
        TextButton(onPressed: ()async{
          await  SubjectController.deleteSubject(subject.id).then((c){
            setState(() {});
            Navigator.pop(context);
          });
        }, child: const Text("Supprimer")),
      ],
    ));
  }

  Widget selectSex() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton(
        value: sexSelected,
        borderRadius: BorderRadius.circular(20),
        hint: const Text("Le sex"),
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        items: List.generate(
          Sex.values.length,
              (index) => DropdownMenuItem(
            value: Sex.values[index],
            child: Text(Sex.values[index].name),
          ),
        ),
        style: TextStyle(color: primaryColor,),
        onChanged: (v) {
          sexSelected =v!;
          setState(() {});
        },
      ),
    );
  }
}
