import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madrassa/constants/colors.dart';
import 'package:madrassa/view/classes.dart';
import 'package:madrassa/view/students.dart';
import 'package:madrassa/view/teachers.dart';
import 'package:madrassa/view/timetable.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage=0;
  void onItemPressed(int index){

  }
  @override
  Widget build(BuildContext context) {
    PageController pageController =PageController();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner_outlined),
      ),
      bottomNavigationBar:BottomNavigationBar(
        onTap: (index){
          setState(() {
            pageController.animateToPage(index, duration: const Duration(milliseconds:400 ), curve: Curves.easeIn);
            _selectedPage=index;
          });
        },
        currentIndex: _selectedPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bookBookmark),label: 'Cours'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.calendarDays),label: 'Programme'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.personChalkboard),label: 'Enseignants'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.graduationCap),label: 'Etudiants'),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            _selectedPage=index;
          });
        },
        children: const [
          Classes(),
          Timetable(),
          Teachers(),
          Students(),
        ],
      ),
    );
  }
}
