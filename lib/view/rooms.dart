import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:madrassa/components/build_text_form_field.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/constants/enums.dart';
import 'package:madrassa/controller/room_controller.dart';
import 'package:madrassa/model/room.dart';
import 'package:madrassa/view/add_room.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  RoomsState createState() => RoomsState();
}

class RoomsState extends State<Rooms> {
  List<Room> rooms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Les Salles"),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: primaryColor,
        children: [
          SpeedDialChild(
            shape: const CircleBorder(),
            label: "Ajouter une seule salle",
            child: const Icon(
              Icons.exposure_plus_1_rounded,
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: primaryColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRoom()));
            },
          ),
          SpeedDialChild(
            shape: const CircleBorder(),
            label: "Ajouter multi-salle",
            child: const Icon(
              Icons.add_home_work_rounded,
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: primaryColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: () {
              TextEditingController salleNumberController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Ajouter multi-salles"),
                  content: buildTextFormField(salleNumberController, "Nombre de salle", TextInputType.number),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(thirdColor),
                      ),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        int nombre = int.parse(salleNumberController.text);
                        showDialog(
                            context: context,
                            builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ));
                        await RoomController.addMultipleRooms(nombre).then((d) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.green),
                      ),
                      child: const Text("Ajouter"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Room>>(
        stream: RoomController.getAllRoomsSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          } else {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              rooms.clear();
              rooms = snapshot.data!;
              existingRooms = rooms;
              return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.meeting_room_rounded),
                        title: Text(
                          rooms[index].name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rooms[index].floor == 0
                                ? "Rez-de-chaussée"
                                : rooms[index].floor == 1
                                    ? "Premier étage"
                                    : "${rooms[index].floor}eme étage"),
                            Text("${rooms[index].chairNumber} chaises"),
                            Text("${rooms[index].tableNumber} tables"),
                          ],
                        ),
                      ));
            }
          }
        },
      ),
    );
  }
}
