import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/view/add_cours.dart';
import 'package:madrassa/view/add_prof.dart';
import 'package:madrassa/view/add_student.dart';
import 'package:madrassa/view/classes.dart';
import 'package:madrassa/view/rooms.dart';
import 'package:madrassa/view/students.dart';
import 'package:madrassa/view/teachers.dart';
import 'package:madrassa/view/timetable.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;
  String _selectedPageTitle='';
  void onItemPressed(int index) {}
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPageTitle),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: primaryColor,
        children: [
          SpeedDialChild(
            shape: const CircleBorder(),
            label: "Scanner QR",
            child: const Icon(
              Icons.qr_code_scanner_outlined,
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            labelBackgroundColor: primaryColor,
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            onTap: () {},
          ),
          SpeedDialChild(
              shape: const CircleBorder(),
              label: "Ajouter un étudiant",
              child: const Icon(
                FontAwesomeIcons.userGraduate,
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              labelBackgroundColor: primaryColor,
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddStudent()));
              }),
          SpeedDialChild(
              shape: const CircleBorder(),
              label: "Ajouter un enseignant",
              child: const Icon(
                Icons.person_add_alt_1_rounded,
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              labelBackgroundColor: primaryColor,
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProf()));
              }),
          SpeedDialChild(
              shape: const CircleBorder(),
              label: "Ajouter une formation",
              child: const Icon(
                FontAwesomeIcons.bookOpenReader,
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              labelBackgroundColor: primaryColor,
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddCours()));
              }),
        ],
        child: const Icon(Icons.menu_rounded),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width*0.75,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage("assets/images/logo_zedi.jpg"),
                    ),
                    Text("Zedi School",style: TextStyle(fontSize: 18 ,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  ],
                ),
                ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Rooms()));
                  },
                  leading: const Icon(FontAwesomeIcons.school),
                  title: const Text("Les salles"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,size: 15,),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: true,
        onTap: (index) {
          switch (index) {
            case 0:_selectedPageTitle="Les Cours";
            case 1:_selectedPageTitle="Le Programme";
            case 2:_selectedPageTitle="Les ensaignants";
            case 3:_selectedPageTitle="Les étudiants";
          }
          setState(() {
            pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
            _selectedPage = index;
          });
        },
        currentIndex: _selectedPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bookBookmark), label: 'Cours', backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.calendarDays), label: 'Programme', backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.personChalkboard), label: 'Enseignants', backgroundColor: Colors.white),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.graduationCap), label: 'Etudiants', backgroundColor: Colors.white),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor.withOpacity(0.4),
        showUnselectedLabels: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            switch (index) {
              case 0:_selectedPageTitle="Les Cours";
              case 1:_selectedPageTitle="Le Programme";
              case 2:_selectedPageTitle="Les ensaignants";
              case 3:_selectedPageTitle="Les étudiants";
            }
            setState(() {
              _selectedPage = index;
            });
          },
          children: const [
            Classes(),
            Timetable(),
            Teachers(),
            Students(),
          ],
        ),
      ),
    );
  }
}
