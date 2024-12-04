import 'package:flutter/material.dart';
import 'package:mon_agenda/agenda_app.dart';
import 'package:mon_agenda/pages/add_event_page.dart';
// Importez d'autres pages nécessaires
import 'package:mon_agenda/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Définir la route initiale (connexion ou ajout d'événements ici)
      initialRoute: '/',
      // Définir les différentes routes
      routes: {
        '/': (context) => const AddEventPage(), // Page initiale (connexion)
        '/home': (context) => AgendaPage(), // Page d'accueil (après connexion)
      },
    );
  }
}