import 'package:flutter/material.dart';
import 'package:mon_agenda/agenda_app.dart';
import 'package:mon_agenda/connexion.dart';
// Importez d'autres pages nécessaires

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
        '/': (context) => const Connexion(), // Page initiale (connexion)
        '/home': (context) => AgendaPage(), // Page d'accueil (après connexion)
      },
    );
  }
}