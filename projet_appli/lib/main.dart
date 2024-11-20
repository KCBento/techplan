import 'package:flutter/material.dart';
import 'package:mon_agenda/pages/add_event_page.dart';
/*import 'package:projet_appli/pages/home_page.dart';*/




void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  setCurrenteIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const [
              /*Text("Accueil"),*/
              /*Text("Liste des conferences"),*/
              Text("Bienvenue sur l'agenda de Techplan")
            ][_currentIndex],
          ),
          body: const [
            /*HomePage(),*/
            /*EventPage(),*/
            AddEventPage()
          ][_currentIndex] /*,*/
          /*bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setCurrenteIndex(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            iconSize: 32,
            elevation: 10,
            items: const [
              /*BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),*/
              /*BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: "Planning"),*/
              /*BottomNavigationBarItem(icon: Icon(Icons.add), label: "Ajout")*/
            ],
          )*/
          ),
    );
  }
}
