import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/components/build_text_form_field.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/cours_crtl.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/controller/payment_crtl.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/payment.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/student_attendance.dart';

class PaymentForm extends StatefulWidget {
  final Student student;

  const PaymentForm({super.key, required this.student});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  TextEditingController priceController = TextEditingController();
  TextEditingController seanceController = TextEditingController();
  Cours? selectedCours;
  Group? selectedGroup;
  double amount = 0.0;
  DateTime paymentDate = DateTime.now();
  int sessionNumber = 1;

  List<Cours> courses = [];
  List<Group> groups = [];

  String events = '', repeatedDays = '';

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  void setGroupTime(Group group) {
    events = group.schedule.map((schedule) {
      return '${intl.DateFormat.MMMMEEEEd("fr").format(schedule.start)} ${schedule.start.hour}:${schedule.start.minute.toString().padLeft(2, '0')} - ${schedule.end.hour}:${schedule.end.minute.toString().padLeft(2, '0')}';
    }).join(', ');

    repeatedDays = "";
    if (group.repeatedDaysOfWeek != null && group.repeatedDaysOfWeek!.isNotEmpty) {
      if (group.repeatedDaysOfWeek!.length < 7) {
        repeatedDays = group.repeatedDaysOfWeek!.map((day) => day.dayNameFr).join(', ');
      } else {
        repeatedDays = "Chaque jour";
      }
      repeatedDays += "\n${group.repeatedDaysOfWeek?.first.start.format(context)} - ${group.repeatedDaysOfWeek?.first.end.format(context)}";
    }
  }

  Future<void> fetchCourses() async {
    if(existingCours.isEmpty) {
      courses = await CoursController.getAllCours();
      existingCours=courses;
    }
    else{
      courses=existingCours;
    }
    setState(() {});
  }

  Future<List<Group>> fetchGroups(Cours? cours) async {
    existingGroups = await GroupController.getAllGroups();
    groups= existingGroups.where((test)=>test.cours?.id==cours?.id).toList();
    if (cours != null) {
    } else {
      groups.clear();
    }
    setState(() {});
    return groups;
  }

  void submitPayment() async {
    if (selectedCours != null && selectedGroup != null && amount > 0) {
      // Check for duplicate payments or any previous record
      bool paymentExists = await PaymentController.checkIfPaymentExists(
        studentId: widget.student.id,
        groupId: selectedGroup!.id,
        coursId: selectedCours!.id,
      );

      if (paymentExists && selectedGroup!.groupeAttendance.last.length<selectedCours!.nombreSeance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment already exists for this course and group.')),
        );
        return;
      }
      selectedGroup!.cours = selectedCours;
      Payment payment = Payment(
        id: '',
        student: widget.student,
        groupe: selectedGroup!,
        amount: amount.toInt(),
        date: paymentDate,
        sessionNumber: sessionNumber,
      );

      // Add the payment to the database
      String paymentSuccess = await PaymentController.addPayment(payment);
      if (paymentSuccess.isNotEmpty) {
        selectedGroup!.students.add(widget.student);

        // Update group attendance records for the student
        if (selectedGroup!.groupeAttendance.isNotEmpty) {
          for (var i = 0; i < selectedGroup!.groupeAttendance.length; i++) {
            bool alreadyExists = selectedGroup!.groupeAttendance.last[i].studentAttendances.any(
                  (attendance) {
                    print(attendance.student.nom);
                    return attendance.student.id == widget.student.id;
                  },
            );
            if (!alreadyExists) {
              print("not already exists");
              selectedGroup!.groupeAttendance.last[i].studentAttendances.add(
                StudentAttendance(
                  id: '',
                  date: selectedGroup!.groupeAttendance.last[i].date,
                  student: widget.student,
                  status: AttendanceStatus.absent, // Adjust as needed
                  createdBy: currentAdmin,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  remarks: 'Non Payé',
                ),
              );
            }
          }
        }

        // Update group data in Firestore or the database
        await GroupController.updateGroup(selectedGroup!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment submitted successfully!')),
          );
          Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding payment. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Cours Dropdown
              selectCours(),
              const SizedBox(height: 16.0),

              // Select Group Dropdown
              DropdownButtonFormField<Group>(
                decoration: const InputDecoration(
                  labelText: 'Select Group',
                  border: OutlineInputBorder(),
                ),
                items: groups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group.name),
                  );
                }).toList(),
                value: selectedGroup,
                onChanged: (value) {
                  setState(() {
                    selectedGroup = value;
                    setGroupTime(selectedGroup!);
                  });
                },
              ),
              if (events.isNotEmpty)
                Center(
                  child: Text(
                    'Le: $events',
                    style: const TextStyle(),
                  ),
                ),
              if (repeatedDays.isNotEmpty)
                Center(
                  child: Text(
                    repeatedDays,
                    style: const TextStyle(),
                  ),
                ),

              const SizedBox(height: 16.0),

              // Amount Field
              buildTextFormField(priceController, "Le Prix", TextInputType.number, readOnly: true),
              const SizedBox(height: 16.0),

              // Session Number Field
              TextFormField(
                controller: seanceController,
                decoration: const InputDecoration(
                  labelText: 'Session Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    sessionNumber = int.tryParse(value) ?? 1;
                    seanceController.text = "$sessionNumber";
                    amount = (selectedCours!.price / selectedCours!.nombreSeance) * sessionNumber;
                    priceController.text = "${amount.toInt()}";
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: submitPayment,
                  child: const Text('Submit Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectCours() {
    return Autocomplete<Cours>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return existingCours;
        }
        return existingCours.where((Cours cours) {
          return cours.name.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
        });
      },
      displayStringForOption: (Cours cours) => cours.name,
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
            labelText: 'Select Cours',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            prefixIcon: const Icon(Icons.book),
            suffixIcon: IconButton(
              icon: focusNode.hasFocus ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
              onPressed: () {
                if (focusNode.hasFocus) {
                  focusNode.unfocus();
                } else {
                  focusNode.requestFocus();
                }
              },
            ),
          ),
        );
      },
      onSelected: (Cours selection) async {
        selectedCours = selection;
        priceController = TextEditingController(text: selectedCours?.price.toString() ?? "");
        amount = double.tryParse(priceController.text) ?? amount;
        seanceController = TextEditingController(text: selectedCours?.nombreSeance.toString() ?? "");
        sessionNumber = int.tryParse(seanceController.text) ?? sessionNumber;
        showDialog(context: context, builder: (context)=>const Center(child: CircularProgressIndicator(),));
         await fetchGroups(selectedCours).then((v){
           groups =v;
           print(groups.length);
           for (var value in groups) {
             print(value.name);
           }
          if (groups.isNotEmpty) {
            selectedGroup = groups.first;
            setGroupTime(selectedGroup!);
          }
           Navigator.pop(context);
        });
        setState(() {});
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Cours> onSelected,
        Iterable<Cours> options,
      ) {
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
                  final Cours cours = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(cours);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: Text(cours.name),
                      subtitle: Text('Group count: ${cours.groups.length}'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
