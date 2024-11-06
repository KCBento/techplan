import 'package:flutter/material.dart';
import 'package:projet_appli/pages/add_event_page.dart';
/*import 'package:projet_appli/pages/home_page.dart';*/
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AgendaApp());
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
}
class AgendaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AgendaPage(),
    );
  }
}

class AgendaPage extends StatefulWidget {
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _selectedDay;
  late Map<DateTime, List<Intervention>> _interventions; // Dictionnaire d'interventions

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Jour sélectionné par défaut
    _interventions = {}; // Initialiser le dictionnaire d'interventions
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

// Classe représentant une intervention
class Intervention {
  String titre;
  String client;
  String statut;
  DateTime date;

  Intervention({
    required this.titre,
    required this.client,
    required this.statut,
    required this.date,
  });
}
