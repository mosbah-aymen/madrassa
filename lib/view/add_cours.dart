import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/cours_crtl.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/controller/room_controller.dart';
import 'package:madrassa/controller/subject_controller.dart';
import 'package:madrassa/controller/teacher_crtl.dart';
import 'package:madrassa/model/cours.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/room.dart';
import 'package:madrassa/model/subject.dart';
import 'package:madrassa/model/teacher.dart';
import 'package:madrassa/view/add_prof.dart';

import '../components/build_text_form_field.dart';

class AddCours extends StatefulWidget {
  const AddCours({
    super.key,
  });

  @override
  State<AddCours> createState() => _AddCoursState();
}

class _AddCoursState extends State<AddCours> {
  Random rand = Random();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController seanceController = TextEditingController();
  int? year;
  int? nombreSeances;
  int? price;
  String? yearLevel, selectedAutreLevel;
  Subject? selectedSubject;
  String newSubjectName = "";
  Level? selectedLevel;
  Teacher? selectedTeacher; // Variable to hold the selected teacher
  Cours? newCoursEmpty;
  List<Group> groups = [
    Group(id: "", name: "Groupe 1", students: [], groupeAttendance: [], schedule: [], cours: null,profPercent: 0),
  ];
  List<TextEditingController> percentController =[TextEditingController()];

  Future<void> _selectDateTimeRange(int groupeIndex, bool isRecurring) async {
    if (isRecurring) {
      // Select the days for recurring schedule
      await _selectRecurrenceDays(groupeIndex).then((selectedDays) async {
        if (selectedDays != null && selectedDays.isNotEmpty) {
          // Select the start time
          TimeOfDay? debut = await showTimePicker(
            context: context,
            initialTime: groups[groupeIndex == 0 ? 0 : groupeIndex - 1].repeatedDaysOfWeek == null || groups[groupeIndex == 0 ? 0 : groupeIndex - 1].repeatedDaysOfWeek!.isEmpty
                ? TimeOfDay.now().replacing(minute: 00)
                : groups[groupeIndex == 0 ? 0 : groupeIndex - 1].repeatedDaysOfWeek!.last.end,
            helpText: "Temps de début de séance :",
          );

          if (debut != null) {
            // Select the end time
            TimeOfDay? fin = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: debut.hour + 1 + (debut.minute + 30) ~/ 60,
                minute: (debut.minute + 30) % 60,
              ),
              helpText: "Temps de fin de séance :",
            );

            if (fin != null) {
              for (int day in selectedDays) {
                DateTime nextDay = _getNextDateForDay(day, DateTime.now()).copyWith(hour: debut.hour, minute: debut.minute);

                RepeatedDay newRepeatedDay = RepeatedDay(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  start: debut,
                  end: fin,
                  dayIndex: day,
                  dayNameFr: _getDayNameFr(day),
                  dayNameAr: _getDayNameAr(day),
                );

                // Check for conflicts in the recurring schedule
                String? checkStatus = _checkForConflict(
                  groupeIndex,
                  DateTimeRange(start: nextDay, end: nextDay.add(Duration(hours: fin.hour - debut.hour, minutes: fin.minute - debut.minute))),
                  groups[groupeIndex].room,
                  newRepeatedDay,
                );

                if (checkStatus == null) {
                  setState(() {
                    groups[groupeIndex].repeatedDaysOfWeek ??= [];
                    groups[groupeIndex].repeatedDaysOfWeek!.add(newRepeatedDay);
                    groups[groupeIndex].repeatedDaysOfWeek!.sort((a, b) => a.nextDay.compareTo(b.nextDay));
                  });
                } else {
                  Fluttertoast.showToast(
                    msg: checkStatus,
                    backgroundColor: Colors.red,
                  );
                }
              }
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: "Aucun jour récurrent sélectionné.",
            backgroundColor: Colors.red,
          );
        }
      });
    } else {
      // Handle non-recurring schedule
      await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2031),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      ).then((pickedDay) async {
        if (pickedDay != null) {
          TimeOfDay? debut = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            helpText: "Temps de début de séance :",
          );

          if (debut != null) {
            TimeOfDay? fin = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: debut.hour + 1 + (debut.minute + 30) ~/ 60,
                minute: (debut.minute + 30) % 60,
              ),
              helpText: "Temps de fin de séance :",
            );

            if (fin != null) {
              DateTime start = DateTime(
                pickedDay.year,
                pickedDay.month,
                pickedDay.day,
                debut.hour,
                debut.minute,
              );
              DateTime end = DateTime(
                pickedDay.year,
                pickedDay.month,
                pickedDay.day,
                fin.hour,
                fin.minute,
              );
              DateTimeRange newRange = DateTimeRange(start: start, end: end);

              // Check for conflicts in the non-recurring schedule
              String? checkStatus = _checkForConflict(groupeIndex, newRange, groups[groupeIndex].room, null);

              if (checkStatus == null) {
                setState(() {
                  groups[groupeIndex].schedule.add(newRange);
                  groups[groupeIndex].schedule.sort((a, b) => a.start.compareTo(b.start));
                });
              } else {
                Fluttertoast.showToast(
                  msg: checkStatus,
                  backgroundColor: Colors.red,
                );
              }
            }
          }
        }
      });
    }
  }

// Helper method to get the next occurrence of a specific day of the week
  DateTime _getNextDateForDay(int day, DateTime currentDate) {
    int daysToAdd = (day - currentDate.weekday) % 7;
    if (daysToAdd <= 0) daysToAdd += 7;
    return currentDate.add(Duration(days: daysToAdd));
  }

// Helper method to get the French name of the day
  String _getDayNameFr(int day) {
    const daysFr = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];
    return daysFr[day - 1];
  }

// Helper method to get the Arabic name of the day
  String _getDayNameAr(int day) {
    const daysAr = ["الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد"];
    return daysAr[day - 1];
  }

// Helper method to check for scheduling conflicts
  String? _checkForConflict(int groupeIndex, DateTimeRange newRange, Room? room, RepeatedDay? day) {
    Group group = groups[groupeIndex];

    // Check conflict with non-recurring schedule
    for (DateTimeRange existingRange in group.schedule) {
      if (newRange.start.isBefore(existingRange.end) && newRange.end.isAfter(existingRange.start)) {
        return "${group.name} a réservé la salle ${room!.name} le : ${DateFormat.MMMEd("fr").format(existingRange.start)}";
      }
    }

    // Check conflict with recurring schedule
    if (day != null && group.repeatedDaysOfWeek != null) {
      for (RepeatedDay existingDay in group.repeatedDaysOfWeek!) {
        if (existingDay.dayIndex == day.dayIndex) {
          DateTime existingStart = DateTime(day.nextDay.year,day.nextDay.month,day.nextDay.day,day.nextDay.hour,day.nextDay.minute);

          DateTime existingEnd = existingDay.nextDay.add(
            Duration(
              hours: existingDay.end.hour - existingDay.start.hour,
              minutes: existingDay.end.minute - existingDay.start.minute,
            ),
          );

          if (newRange.start.isBefore(existingEnd) && newRange.end.isAfter(existingStart)) {
            return "${group.name} a réservé la salle ${room!.name} le : ${existingDay.dayNameFr}";
          }
        }
      }
    }

    // Optionally, check conflicts with the room's schedule
    if (room != null) {
      for (Cours cours in existingCours) {
        for (Group otherGroup in cours.groups.where((test) => test.room != null && test.room!.id == room.id)) {
          for (DateTimeRange existingRange in otherGroup.schedule) {
            if (newRange.start.isBefore(existingRange.end) && newRange.end.isAfter(existingRange.start)) {
              return "${otherGroup.name} de '${cours.name}' dans la salle ${room.name}.";
            }
          }

          if (day != null && otherGroup.repeatedDaysOfWeek != null) {
            for (RepeatedDay existingDay in otherGroup.repeatedDaysOfWeek!) {
              if (existingDay.dayIndex == day.dayIndex) {
                DateTime existingStart = DateTime(existingDay.nextDay.year,existingDay.nextDay.month,existingDay.nextDay.day,existingDay.start.hour,existingDay.start.minute);
                DateTime existingEnd = DateTime(existingDay.nextDay.year,existingDay.nextDay.month,existingDay.nextDay.day,existingDay.end.hour,existingDay.end.minute);
                if (newRange.start.isBefore(existingEnd) && newRange.end.isAfter(existingStart)) {
                  return "Conflit détecté avec une autre séance récurrente dans la même salle.";
                }
              }
            }
          }
        }
      }
      for (Group otherGroup in groups) {
        if (otherGroup.name != group.name && otherGroup.room != null && otherGroup.room!.id == room.id) {
          for (DateTimeRange existingRange in otherGroup.schedule) {
            if (newRange.start.isBefore(existingRange.end) && newRange.end.isAfter(existingRange.start)) {
              return "${otherGroup.name} a réservé la salle '${room.name}' au meme temps!";
            }
          }

          if (day != null && otherGroup.repeatedDaysOfWeek != null) {
            for (RepeatedDay existingDay in otherGroup.repeatedDaysOfWeek!) {
              if (existingDay.dayIndex == day.dayIndex) {
                DateTime existingStart = existingDay.nextDay;
                DateTime existingEnd = existingDay.nextDay.add(
                  Duration(
                    hours: existingDay.end.hour - existingDay.start.hour,
                    minutes: existingDay.end.minute - existingDay.start.minute - 1,
                  ),
                );

                if (newRange.start.isBefore(existingEnd) && newRange.end.isAfter(existingStart)) {
                  return "${otherGroup.name} a réservé la salle '${room.name}' chaque '${existingDay.dayNameFr}' \nDu : ${existingDay.start.format(context)} au : ${existingDay.end.format(context)}";
                }
              }
            }
          }
        }
      }
    }

    // No conflict detected
    return null;
  }

  Future<void> _showRecurrenceTypeDialog(int groupeIndex) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir le type de planification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Planification unique'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectDateTimeRange(groupeIndex, false); // Pass false for one-time
                },
              ),
              ListTile(
                title: const Text('Planification récurrente'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectDateTimeRange(groupeIndex, true); // Pass true for recurring
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<int>?> _selectRecurrenceDays(int groupIndex) async {
    List<String> daysOfWeekNames = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    List<int> daysOfWeek = [
      7,
      1,
      2,
      3,
      4,
      5,
      6,
    ];
    List<int> selectedDays = [];
    if (groups[groupIndex].repeatedDaysOfWeek != null) {
      for (var value in groups[groupIndex].repeatedDaysOfWeek!) {
        selectedDays.add(value.dayIndex);
      }
      setState(() {});
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sélectionner les jours de la semaine'),
              content: SingleChildScrollView(
                child: Column(
                  children: List.generate(7, (index) {
                    return CheckboxListTile(
                      title: Text(daysOfWeekNames[index]),
                      value: selectedDays.contains(daysOfWeek[index]),
                      onChanged: (bool? value) {
                        if (value != null) {
                          if (value && !selectedDays.contains(daysOfWeek[index])) {
                            selectedDays.add(daysOfWeek[index]);
                          } else {
                            selectedDays.remove(daysOfWeek[index]);
                          }
                          setState(() {});
                        }
                      },
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirmer'),
                  onPressed: () {
                    Navigator.of(context).pop(selectedDays);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    return selectedDays.isNotEmpty ? selectedDays : null;
  }

  void _saveCours() async {
    // Validate input
    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez entrer le nom du cours", backgroundColor: Colors.red);
      return;
    }
    if (selectedTeacher == null) {
      Fluttertoast.showToast(msg: "Veuillez sélectionner un enseignant pour ce cours", backgroundColor: Colors.red);
      return;
    }
    if (selectedLevel == null) {
      Fluttertoast.showToast(msg: "Veuillez sélectionner le niveau de ce cours", backgroundColor: Colors.red);
      return;
    }
    if (selectedSubject == null) {
      Fluttertoast.showToast(msg: "Veuillez sélectionner le thème de ce cours", backgroundColor: Colors.red);
      return;
    }
    if (yearLevel == null) {
      Fluttertoast.showToast(msg: "Veuillez sélectionner l'année de ce cours", backgroundColor: Colors.red);
      return;
    }
    nombreSeances = int.tryParse(seanceController.text);
    if (nombreSeances == null) {
      Fluttertoast.showToast(msg: "Merci de spécifier le nombre de séances", backgroundColor: Colors.red);
      return;
    }
    price = int.tryParse(priceController.text);
    if (price == null) {
      Fluttertoast.showToast(msg: "Merci de spécifier un prix", backgroundColor: Colors.red);
      return;
    }
    // Validate groups
    for (int i=0; i <groups.length; i++) {
      if (groups[i].schedule.isEmpty && (groups[i].repeatedDaysOfWeek == null || groups[i].repeatedDaysOfWeek!.isEmpty)) {
        Fluttertoast.showToast(msg: "Veuillez ajouter au moins une plage horaire pour le groupe ${groups[i].name}", backgroundColor: Colors.red);
        return;
      }
      if (groups[i].room == null) {
        Fluttertoast.showToast(msg: "Veuillez sélectionner une salle pour le groupe ${groups[i].name}", backgroundColor: Colors.red);
        return;
      }
      groups[i].profPercent=double.tryParse(percentController[i].text)??0;
      if (groups[i].profPercent == 0) {
        Fluttertoast.showToast(msg: "Merci de spécifier un pourcentage de l'enseignant pour le groupe ${groups[i].name}", backgroundColor: Colors.red);
        return;
      }
    }

    // Prepare course and group data
    List<DateTimeRange> selectedDateTimeRanges = [];
    for (Group group in groups) {
      selectedDateTimeRanges.addAll(group.schedule);
    }

    Cours newCours = Cours(
        id: '', // Generate or get this id
        name: nameController.text,
        teacher: selectedTeacher!,
        level: selectedLevel!,
        subject: selectedSubject!,
        year: yearLevel!,
        createdAt: DateTime.now(),
        isRepeat: false, // Set based on user input if applicable
        daysWeek: selectedDateTimeRanges,
        groups: groups,
        price: price!,
        nombreSeance: nombreSeances!,
    );

    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
        barrierDismissible: false);
    // Save groups and course
    try {
      for (int i = 0; i < groups.length; i++) {
        newCours.groups[i].cours = newCours;
        String id = await GroupController.createGroup(groups[i]);
        newCours.groups[i].id = id;
      }
      await CoursController.createCours(newCours);
      Fluttertoast.showToast(msg: "Cours ajouté avec succès", backgroundColor: Colors.green);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur lors de l'ajout du cours : ${e.toString()}", backgroundColor: Colors.red);
    }

    // Clear the form after saving
    setState(() {
      nameController.clear();
      selectedTeacher = null;
      selectedLevel = null;
      selectedSubject = null;
      yearLevel = null;
      groups.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    nameController.text =
        "${selectedSubject == null ? "" : "${selectedSubject!.name} "}${selectedLevel == null || yearLevel == null ? "" : yearLevel!}${selectedTeacher == null ? "" : "${selectedTeacher!.sex == Sex.female ? ' الأستاذة ' : ' الأستاذ '}${selectedTeacher!.name}"}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une formation"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTextFormField(nameController, "Nom De Cours/formation", TextInputType.text, readOnly: false),
              const SizedBox(height: 20),
              setPriceAndPercent(),
              const SizedBox(height: 20),
              selectTeacher(),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProf()));
                },
                child: const Text(
                  "cliker pour ajouter un nouveau enseignant",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              selectSubject(),
              const SizedBox(height: 20),
              selectLevel(),
              const SizedBox(height: 20),
              selectYear(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Les Groupes:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              groupsWidget(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCours,
                child: const Text("Enregistrer le cours"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget setPriceAndPercent() {
    return Row(
      children: [
        Expanded(child: buildTextFormField(priceController, "Le Prix", TextInputType.number, isRequired: true)),
        const SizedBox(
          width: 5,
        ),
        Expanded(child: buildTextFormField(seanceController, "NºSéances", TextInputType.number, isRequired: true)),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  Widget groupsWidget() {

    return Column(
      children: [
        ...List.generate(
          groups.length,
          (indexGroupe) {
            return Card(
              color: primaryColor.withOpacity(0.09),
              elevation: 0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Text(
                            "Groupe ${indexGroupe + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              groups.removeAt(indexGroupe);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildTextFormField(percentController[indexGroupe], "Prof %", TextInputType.number, isRequired: true,fillColor: Colors.white),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: selectRoom(indexGroupe),
                  ),
                  const Divider(),
                  Text(
                    "Plage Horaire du groupe ${indexGroupe + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  if (groups[indexGroupe].repeatedDaysOfWeek != null && groups[indexGroupe].repeatedDaysOfWeek!.length == 7)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        collapsedTextColor: Colors.white,
                        collapsedBackgroundColor: thirdColor,
                        collapsedIconColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black,
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text("Tous les jours"),
                        children: [
                          ...List.generate(groups[indexGroupe].repeatedDaysOfWeek!.length, (index) {
                            return dayTimeWidget(
                                repeatedDay: groups[indexGroupe].repeatedDaysOfWeek![index],
                                onDeletePressed: () {
                                  setState(() {
                                    groups[indexGroupe].repeatedDaysOfWeek!.removeAt(index);
                                  });
                                });
                          }),
                        ],
                      ),
                    ),
                  if (groups[indexGroupe].repeatedDaysOfWeek != null && groups[indexGroupe].repeatedDaysOfWeek!.length != 7)
                    ...List.generate(groups[indexGroupe].repeatedDaysOfWeek!.length, (index) {
                      return dayTimeWidget(
                          repeatedDay: groups[indexGroupe].repeatedDaysOfWeek![index],
                          onDeletePressed: () {
                            setState(() {
                              groups[indexGroupe].repeatedDaysOfWeek!.removeAt(index);
                            });
                          });
                    }),
                  ...List.generate(
                    groups[indexGroupe].schedule.length,
                    (index) => dayTimeWidget(
                        range: groups[indexGroupe].schedule[index],
                        onDeletePressed: () {
                          setState(() {
                            groups[indexGroupe].schedule.removeAt(index);
                          });
                        }),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      _showRecurrenceTypeDialog(indexGroupe);
                    },
                    child: const Text("Ajouter une plage horaire"),
                  ),
                ],
              ),
            );
          },
        ),
        TextButton(
          onPressed: () {
            setState(() {
              groups.add(Group(
                id: "",
                name: "Groupe ${groups.length + 1}",
                cours: null,
                students: [],
                groupeAttendance: [],
                schedule: [],
                room: null,
                repeatedDaysOfWeek: [],
                profPercent: 0,
              ));
            });
            percentController.add(TextEditingController());
          },
          child: const Text("Ajouter un groupe"),
        ),
      ],
    );
  }

  Widget dayTimeWidget({Function()? onDeletePressed, RepeatedDay? repeatedDay, DateTimeRange? range}) {
    if (repeatedDay != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          tileColor: Colors.primaries.elementAt(5 + rand.nextInt(3)).withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: const Center(
              child: Icon(Icons.repeat),
            ),
          ),
          title: Text(
            "Chaque ${repeatedDay.dayNameFr}",
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
            "${repeatedDay.start.format(context)} - ${repeatedDay.end.format(context)}"
            "\nProchaine ${DateFormat.MMMd("fr").format(repeatedDay.nextDay)}",
            style: const TextStyle(color: Colors.black),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: onDeletePressed,
          ),
        ),
      );
    } else if (range != null) {
      return ListTile(
        tileColor: Colors.primaries.elementAt(5 + rand.nextInt(3)).withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(Icons.date_range_rounded),
          ),
        ),
        title: Text(
          DateFormat('EEEE d MMM y', 'fr').format(
            range.start,
          ),
        ),
        subtitle: Text(
          "${DateFormat('h:mm a').format(range.start)} - ${DateFormat('h:mm a').format(range.end)}",
          style: const TextStyle(color: Colors.black),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDeletePressed,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget selectRoom(int groupIndex) {
    if (existingRooms.isEmpty) {
      RoomController.getAllRooms().then((v) {
        setState(() {
          existingRooms = v;
        });
      });
    }

    List<Room> rooms = existingRooms;
    return Autocomplete<Room>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return rooms;
        }
        return rooms.where((Room room) {
          return room.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) ||
              room.floor.toString().contains(textEditingValue.text);
        });
      },
      displayStringForOption: (Room room) => room.name,
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
            labelText: 'Sélectionner la salle',
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
              Icons.meeting_room_rounded,
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
            if (groups[groupIndex].room != null || textEditingController.text != groups[groupIndex].room!.name || groups[groupIndex].room == null || textEditingController.text.isEmpty) {
              groups[groupIndex].room = null;
            }
          },
        );
      },
      onSelected: (Room selection) {
        groups[groupIndex].room = selection;
        setState(() {});
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Room> onSelected, Iterable<Room> options) {
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
                  final Room room = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(room);
                    },
                    child: ListTile(
                      leading: Icon(Icons.meeting_room_rounded, color: secondaryColor),
                      title: Text(room.name),
                      subtitle: Text("Étage: ${room.floor}"),
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

  Widget selectYear() {
    return selectedLevel == null
        ? const SizedBox()
        : selectedLevel!.index == Level.autre.index
            ? selectAutreLevel()
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<int>(
                  key: const Key('value: year'),
                  value: year,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(20),
                  hint: const Text("Selectionner l'année"),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  items: List.generate(
                    selectedLevel == Level.primaire
                        ? 5
                        : selectedLevel == Level.moyene
                            ? 4
                            : selectedLevel == Level.secondaire
                                ? 3
                                : 0, // No need to check for 'autre' here, handled separately
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text("${index + 1} A${selectedLevel!.name.characters.first.toUpperCase()}"),
                    ),
                  ),
                  style: TextStyle(
                    color: primaryColor,
                  ),
                  onChanged: (v) {
                    setState(() {
                      year = v;
                      yearLevel = "${year}A${selectedLevel!.name.characters.first.toUpperCase()}";
                    });
                  },
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
      child: DropdownButton<Level>(
        value: selectedLevel,
        isExpanded: true,
        borderRadius: BorderRadius.circular(20),
        hint: const Text("Selectionner le niveau"),
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        items: Level.values.map((level) {
          return DropdownMenuItem(
            value: level,
            child: Text(level.name.toUpperCase()),
          );
        }).toList(),
        style: TextStyle(
          color: primaryColor,
        ),
        onChanged: (v) {
          setState(() {
            if (selectedLevel != v) {
              selectedLevel = v;
              year = 1;
              yearLevel = "${year}A${selectedLevel!.name.characters.first.toUpperCase()}";
            }
          });
        },
      ),
    );
  }

  Widget selectAutreLevel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        key: const Key('value: yearLevel,'),
        isExpanded: true,
        value: selectedAutreLevel,
        borderRadius: BorderRadius.circular(20),
        hint: const Text("Selectionner le niveau"),
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        items: AutreLevel.values.map((autre) {
          print(autre.name);
          return DropdownMenuItem(
            key: Key(autre.name),
            value: autre.name,
            child: Text(autre.name),
          );
        }).toList(),
        style: TextStyle(
          color: primaryColor,
        ),
        onChanged: (v) {
          setState(() {
            selectedAutreLevel = v;
            yearLevel = v;
          });
        },
      ),
    );
  }

  Widget selectSubject() {
    if (existingSubjects.isEmpty) {
      SubjectController.getAllSubjects().then((v) => {
            setState(() {
              existingSubjects = v;
            })
          });
    }
    List<Subject> subjects = existingSubjects;
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
              filteredSubjects.add(Subject(name: textEditingValue.text, id: ""));
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
            if (selectedSubject != null) {
              textEditingController.text = selectedSubject!.name;
            }
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
                newSubjectName = s;
                setState(() {});
              },
            );
          },
          onSelected: (Subject selection) async {
            if (selection.id == "") {
              // Check for the "Add new" option
              selectedSubject = await SubjectController.createSubject(Subject(name: newSubjectName, id: ""));
            } else {
              selectedSubject = selection;
            }
            setState(() {});
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
                        trailing: subject.id.isEmpty
                            ? const Icon(
                                Icons.add_circle_outline_outlined,
                                color: Colors.green,
                              )
                            : GestureDetector(
                                onTap: () async {
                                  await _deleteSubject(subject).then((v) {
                                    existingSubjects.removeWhere((s) => s.id == subject.id);
                                    setState(() {});
                                  });
                                },
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                )),
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
  }

  Widget selectTeacher() {
    if (existingTeachers.isEmpty) {
      TeacherController.getAllTeachers().then((v) {
        setState(() {
          existingTeachers = v;
        });
      });
    }
    List<Teacher> teachers = existingTeachers;

    return Autocomplete<Teacher>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return teachers;
        }
        return teachers.where((Teacher teacher) {
          return teacher.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) ||
              teacher.phone.startsWith(textEditingValue.text);
        });
      },
      displayStringForOption: (Teacher teacher) => teacher.name,
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
            labelText: 'Sélectionner un enseignant',
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
              Icons.person_search_rounded,
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
                  textEditingController.clear();
                  focusNode.requestFocus();
                } else {
                  focusNode.unfocus();
                }
              },
            ),
          ),
          onChanged: (s) {
            if (textEditingController.text != selectedTeacher?.name || selectedTeacher == null || textEditingController.text.isEmpty) {
              selectedTeacher = null;
              selectedSubject = null;
            }
          },
        );
      },
      onSelected: (Teacher selection) {
        selectedTeacher = selection;
        selectedSubject = selectedTeacher!.subject;
        setState(() {});
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Teacher> onSelected, Iterable<Teacher> options) {
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
                  if (options.isEmpty) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProf()));
                      },
                      title: const Text("Ajouter un enseignant"),
                    );
                  }
                  final Teacher teacher = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(teacher);
                    },
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.personChalkboard, color: teacher.sex == Sex.male ? secondaryColor : thirdColor),
                      title: Text(teacher.name),
                      subtitle: Text(teacher.subject.name),
                      trailing: Text(teacher.level == Level.autre ? "irrégulier" : teacher.level.name),
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

  Future _deleteSubject(Subject subject) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Supprimer une Matiere"),
              content: const Text("Voulez-vous vraiment supprimer cette matiere? "),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Annuler")),
                TextButton(
                    onPressed: () async {
                      await SubjectController.deleteSubject(subject.id).then((c) {
                        setState(() {});
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Supprimer")),
              ],
            ));
  }
}
