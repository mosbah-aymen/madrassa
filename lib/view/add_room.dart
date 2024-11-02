import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:madrassa/components/build_text_form_field.dart';
import 'package:madrassa/controller/room_controller.dart';
import 'package:madrassa/model/room.dart';

class AddRoom extends StatefulWidget {
  const AddRoom({super.key});

  @override
  AddRoomState createState() => AddRoomState();
}

class AddRoomState extends State<AddRoom> {
  TextEditingController nameController =TextEditingController();
  TextEditingController floorController =TextEditingController(text: "0");
  TextEditingController chairsController =TextEditingController();
  TextEditingController tablesController =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une salle"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildTextFormField(nameController, "Nom du Salle", TextInputType.name),
                buildTextFormField(floorController, "Etage", TextInputType.number),
                buildTextFormField(chairsController, "Nombre de chaise", TextInputType.number),
                buildTextFormField(tablesController, "Nombre de table", TextInputType.number),
                ElevatedButton(onPressed: ()async{
                  if(nameController.text.isEmpty){
                    Fluttertoast.showToast(msg: "Ajouter un nom pour la salle");
                  }
                  else{
                    int floor = int.parse(floorController.text);
                    int chairNumber = int.parse(chairsController.text);
                    int tableNumber = int.parse(tablesController.text);
                    RoomController.addRoom(Room(id: '', name: nameController.text, createdAt: DateTime.now(), floor: floor, tableNumber: tableNumber, chairNumber: chairNumber,),).then((v){
                      Navigator.pop(context);
                    },);
                  }
                }, child: const Text("Ajouter"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
