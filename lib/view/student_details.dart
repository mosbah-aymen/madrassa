import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:madrassa/components/student_carte.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/groupe_controller.dart';
import 'package:madrassa/controller/student_crtl.dart';
import 'package:madrassa/model/groupe.dart';
import 'package:madrassa/model/groupe_attendance.dart';
import 'package:madrassa/model/student.dart';
import 'package:madrassa/model/student_attendance.dart';
import 'package:madrassa/view/payment_form.dart';
import 'package:madrassa/view/payment_history_student.dart';
import 'package:printing/printing.dart';

class StudentDetails extends StatefulWidget {
  final Student student;

  const StudentDetails({super.key, required this.student});

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  final ImagePicker _picker = ImagePicker();
  File? _studentPhoto;
  List<Group> groups = [];
  Color mainColor =primaryColor;
  Future<void> _takePhoto(bool fromCamera) async {
    final XFile? photo = await _picker.pickImage(source: fromCamera?ImageSource.camera:ImageSource.gallery);

    if (photo != null) {
      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square cropping
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _studentPhoto = File(croppedFile.path);
        });

        // Save the cropped image
        await StudentController.updateStudent(widget.student, _studentPhoto!)
            .then((_) {
          widget.student.imageUrl=_studentPhoto!.path;
              existingStudents[existingStudents.indexWhere((test)=>test.id==widget.student.id)]=widget.student;
              setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo updated successfully!')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image cropping canceled.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo selected.')),
      );
    }
  }

  Future<Uint8List?> captureWidgetAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing widget: $e");
      return null;
    }
  }

  Future<void> printCapturedImage(Uint8List imageBytes) async {
    await Printing.layoutPdf(
      onLayout: (format) async {
        final pdf = pw.Document();
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(2),
            build: (context) => pw.Image(image,
            height: 150,
            alignment: const pw.Alignment(2,2)),
          ),
        );
        return pdf.save();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    mainColor = widget.student.sex.index==Sex.male.index?primaryColor:thirdColor;
  }


  @override
  Widget build(BuildContext context) {
    print(widget.student.imageUrl);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: mainColor,
        actionsIconTheme: IconThemeData(
          color: mainColor,
        ),
        title: Text(
          "Détails de l'étudiant",
          style: TextStyle(
            color: mainColor
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentHistoryStudent(student: widget.student)));
              },
              icon: const Icon(Icons.history))
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert_rounded,
        backgroundColor: mainColor,

        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            label: "Prendre une photo",
            onTap:()=> _takePhoto(true),
            shape: const CircleBorder(),
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: mainColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.image_rounded),
            label: "Importer une image",
            shape: const CircleBorder(),
            onTap:()=> _takePhoto(false),
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: mainColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.medical_information_rounded),
            shape: const CircleBorder(),
            label: "Carte de l'étudiant",
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: mainColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: (){
              showDialog(context: context, builder: (context)=>AlertDialog(
                backgroundColor: Colors.transparent,
                content: RotatedBox(
                    quarterTurns: 45,
                    child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: StudentCard(student: widget.student,))),

              actions: [
                ElevatedButton(onPressed: ()async{
                  Uint8List? imageBytes = await captureWidgetAsImage(_repaintBoundaryKey);
                  if (imageBytes != null) {
                    await printCapturedImage(imageBytes);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to capture widget!")),
                    );
                  }

                },

                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black)
                    ),
                    child: const Text("Imprimer"))
              ],),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit_rounded),
            label: "Modifier les détails",
            backgroundColor: mainColor,
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            labelBackgroundColor: mainColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: () {
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.delete_rounded),
            label: "Supprimer l'étudiant",
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            labelBackgroundColor: mainColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: () {
            },
          ),
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
                    child: Hero(
                      tag: widget.student.id,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _studentPhoto != null
                            ? FileImage(_studentPhoto!)
                            : widget.student.imageUrl.isNotEmpty ? FileImage(File(widget.student.imageUrl))
                                : const AssetImage("assets/images/profile.png") as ImageProvider,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.student.nom} ${widget.student.prenom}\n${widget.student.nomArab} ${widget.student.prenomArab}',
                    maxLines: 4,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: mainColor,
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
              Divider(color: mainColor),
               Text(
                "Les Séances",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: mainColor,
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

                  groups = snapshot.data!.where((test) => test.groupeAttendance.length % test.cours!.nombreSeance < test.cours!.nombreSeance).toList();

                  return Column(
                    children: List.generate(
                      groups.length,
                      (groupIndex) {
                        Group group = groups[groupIndex];
                        return Card(
                          color: mainColor,
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
                              ...List.generate(
                                  group.groupeAttendance.length,
                                  (month) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ExpansionTile(
                                          title: Text(
                                            "Mois: ${month + 1}",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                          ),
                                          iconColor: Colors.white,
                                          collapsedIconColor: Colors.white,
                                          children: List.generate(
                                            group.groupeAttendance[month].length,
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
                                                  studentAttendance.remarks.isNotEmpty ? studentAttendance.remarks : studentAttendance.status.name,
                                                  style: TextStyle(
                                                    color: studentAttendance.remarks.isNotEmpty
                                                        ? Colors.orange
                                                        : studentAttendance.status == AttendanceStatus.late
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
                                      ))
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
      leading: Icon(icon, color: mainColor),
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
          color: mainColor,
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
                  (groupIndex) => Padding(
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
                                "Êtes-vous sûr de vouloir sélectionner ce groupe:\n ${groups[groupIndex].cours?.name ?? ""}\n ${groups[groupIndex].name}",
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
                                    if (groups[groupIndex].groupeAttendance.isEmpty) {
                                      groups[groupIndex].groupeAttendance.add([]);
                                    }
                                    if (groups[groupIndex].groupeAttendance.last.isEmpty) {
                                      GroupeAttendance newSession = GroupeAttendance(
                                        date: DateTime.now(),
                                        createdBy: currentAdmin,
                                        studentAttendances: List.generate(
                                            groups[groupIndex].students.length,
                                            (stIndex) => StudentAttendance(
                                                  id: '',
                                                  date: DateTime.now(),
                                                  student: groups[groupIndex].students[stIndex],
                                                  status: groups[groupIndex].students[stIndex].id == widget.student.id ? AttendanceStatus.present : AttendanceStatus.absent,
                                                  createdBy: currentAdmin,
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  remarks: '',
                                                )),
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        id: '',
                                      );
                                      groups[groupIndex].groupeAttendance.last.add(newSession);
                                    } else {
                                      groups[groupIndex].groupeAttendance.last.sort((a, b) => a.date.compareTo(b.date));
                                      int x = groups[groupIndex].groupeAttendance.last.last.studentAttendances.indexWhere((test) => test.student.id == widget.student.id);
                                      if (x >= 0) {
                                        groups[groupIndex].groupeAttendance.last.last.studentAttendances[x].status = AttendanceStatus.present;
                                        groups[groupIndex].groupeAttendance.last.last.studentAttendances[x].remarks = '';
                                        groups[groupIndex].groupeAttendance.last.last.studentAttendances[x].updatedAt = DateTime.now();
                                        groups[groupIndex].groupeAttendance.last.last.studentAttendances[x].createdAt = DateTime.now();
                                        groups[groupIndex].groupeAttendance.last.last.studentAttendances[x].createdBy = currentAdmin;
                                      }
                                    }
                                    await GroupController.updateGroup(groups[groupIndex]).then((v) {
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
                        groups[groupIndex].cours?.name ?? "",
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(groups[groupIndex].name),
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
