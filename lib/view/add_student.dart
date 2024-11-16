import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:madrassa/components/build_text_form_field.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/student_crtl.dart';
import 'package:madrassa/model/student.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController nomArabController = TextEditingController();
  final TextEditingController prenomArabController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController phone2Controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Sex? _selectedSex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un étudiant"),
      ),
      bottomNavigationBar:                 Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          onPressed: () {
            // Validate the form
            if (_formKey.currentState!.validate()) {
              if (_selectedSex == null) {
                Fluttertoast.showToast(msg: 'Le sexe est requis');
                return;
              }
              // If all validations pass
              Student student = Student(
                id: "",
                nom: nomController.text,
                prenom: prenomController.text,
                nomArab: nomArabController.text,
                prenomArab: prenomArabController.text,
                groups: [],
                email: emailController.text,
                phone1: phone1Controller.text,
                phone2: phone2Controller.text,
                sex: _selectedSex!,
                address: addressController.text,
                imageUrl: "",
              );
              StudentController.createStudent(student, null);
            }
          },
          child: const Text("Ajouter"),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Form key to manage validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // "champ obligatoire" message above the fields
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(child: buildTextFormField(nomController, "Nom :", TextInputType.text,isRequired: true)),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(child: buildTextFormField(prenomController, "Prénom :", TextInputType.text,isRequired: true)),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Expanded(child: buildTextFormField(nomArabController, "Nom (Arabe) :", TextInputType.text)),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(child: buildTextFormField(prenomArabController, "Prénom (Arabe) :", TextInputType.text)),
                  ],
                ),



                Row(
                  children: [
                    Expanded(child: buildTextFormField(phone1Controller, "Téléphone 1 :", TextInputType.phone,isRequired: true)),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(child: buildTextFormField(phone2Controller, "Téléphone 2 :", TextInputType.phone)),
                  ],
                ),
                buildTextFormField(emailController, "Email :", TextInputType.emailAddress),
                buildTextFormField(addressController, "Adresse :", TextInputType.text),

                _buildSexSelector(), // Gender selection with validation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSexSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Homme'),
                  leading: Radio<Sex>(
                    value: Sex.male,
                    groupValue: _selectedSex,
                    onChanged: (Sex? value) {
                      setState(() {
                        _selectedSex = value;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Femme'),
                  leading: Radio<Sex>(
                    value: Sex.female,
                    groupValue: _selectedSex,
                    onChanged: (Sex? value) {
                      setState(() {
                        _selectedSex = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
