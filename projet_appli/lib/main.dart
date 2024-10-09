import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AgendaApp());
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Agenda'),
      ),
      body: Column(
        children: [
          TableCalendar<Intervention>(
            firstDay: DateTime.now().subtract(Duration(days: 365)), // Un an en arrière
            lastDay: DateTime.now().add(Duration(days: 365)), // Un an en avant
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // Met à jour le jour sélectionné
              });
            },
            eventLoader: (day) {
              return _interventions[day] ?? []; // Charge les interventions pour le jour sélectionné
            },
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () => _showAddInterventionDialog(context), // Ouvrir la boîte de dialogue pour ajouter une intervention
            child: Text('Ajouter une intervention'),
          ),
          Expanded(
            child: _buildInterventionList(), // Liste des interventions pour le jour sélectionné
          ),
        ],
      ),
    );
  }

  // Fonction pour afficher la liste des interventions
  Widget _buildInterventionList() {
    final interventionsForSelectedDay = _interventions[_selectedDay] ?? [];
    return ListView.builder(
      itemCount: interventionsForSelectedDay.length,
      itemBuilder: (context, index) {
        final intervention = interventionsForSelectedDay[index];
        return ListTile(
          title: Text(intervention.titre),
          subtitle: Text('Client: ${intervention.client} - Statut: ${intervention.statut}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditInterventionDialog(context, intervention), // Éditer l'intervention
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeIntervention(intervention), // Supprimer l'intervention
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour afficher la boîte de dialogue d'ajout d'intervention
  void _showAddInterventionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final clientController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une intervention'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Titre de l\'intervention'),
              ),
              TextField(
                controller: clientController,
                decoration: InputDecoration(labelText: 'Client'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final client = clientController.text;
                if (title.isNotEmpty && client.isNotEmpty) {
                  _addIntervention(Intervention(
                    titre: title,
                    client: client,
                    statut: 'En attente',
                    date: _selectedDay,
                  ));
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                }
              },
              child: Text('Ajouter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fermer la boîte de dialogue sans ajouter
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour ajouter une intervention
  void _addIntervention(Intervention intervention) {
    setState(() {
      if (_interventions[_selectedDay] == null) {
        _interventions[_selectedDay] = [];
      }
      _interventions[_selectedDay]!.add(intervention); // Ajouter l'intervention à la date
    });
  }

  // Fonction pour supprimer une intervention
  void _removeIntervention(Intervention intervention) {
    setState(() {
      _interventions[_selectedDay]?.remove(intervention); // Supprimer l'intervention de la liste
    });
  }

  // Fonction pour afficher la boîte de dialogue d'édition d'intervention
  void _showEditInterventionDialog(BuildContext context, Intervention intervention) {
    final titleController = TextEditingController(text: intervention.titre);
    final clientController = TextEditingController(text: intervention.client);
    final statusController = TextEditingController(text: intervention.statut);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier l\'intervention'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Titre de l\'intervention'),
              ),
              TextField(
                controller: clientController,
                decoration: InputDecoration(labelText: 'Client'),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(labelText: 'Statut'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final client = clientController.text;
                final status = statusController.text;
                if (title.isNotEmpty && client.isNotEmpty && status.isNotEmpty) {
                  setState(() {
                    intervention.titre = title; // Modifier le titre
                    intervention.client = client; // Modifier le client
                    intervention.statut = status; // Modifier le statut
                  });
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                }
              },
              child: Text('Sauvegarder'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fermer la boîte de dialogue sans enregistrer
              child: Text('Annuler'),
            ),
          ],
        );
      },
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
