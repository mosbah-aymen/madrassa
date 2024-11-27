import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:madrassa/view/my_home_page.dart';
import 'constants/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madrassa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: primaryColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
        fontFamily: 'Ubuntu',
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconTheme: IconThemeData(
              color: primaryColor,
            ),
            titleTextStyle: TextStyle(
              color: primaryColor,
              fontSize: 22,
            ),
            elevation: 0),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: primaryColor)
          ),focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: primaryColor,width: 1.5)
        ),
          labelStyle: TextStyle(color: secondaryColor,),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(primaryColor),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          )
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          dayForegroundColor: WidgetStatePropertyAll(secondaryColor),
          cancelButtonStyle:  ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(primaryColor),
          ),
          confirmButtonStyle:  ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(primaryColor),
          ),
          dayBackgroundColor: WidgetStatePropertyAll(primaryColor),

        ),
          expansionTileTheme: ExpansionTileThemeData(
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              backgroundColor: primaryColor.withOpacity(0.1),
              collapsedBackgroundColor: primaryColor.withOpacity(0.1)
          ),

      ),
      home: const MyHomePage(),
    );
  }
}
