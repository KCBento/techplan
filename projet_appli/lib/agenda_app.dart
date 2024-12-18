import 'package:flutter/material.dart';
import 'package:mon_agenda/connexion.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart'; // Ajout de l'import pour formater la date
import '../database.dart';

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
  late Map<DateTime, List<Intervention>> _interventions;
  String nomTechnicien = "";

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _interventions = {};
    _loadInterventionsForTechnician();
    _loadTechnicianName();
  }

  Future<void> _loadInterventionsForTechnician() async {
    int technicianId = await DatabaseHelper().getTechnicianId();
    List<Intervention> interventions = await DatabaseHelper().fetchInterventionsForTechnician(technicianId);

    setState(() {
      _interventions.clear();
      for (var intervention in interventions) {
        DateTime date = DateTime(intervention.debut.year, intervention.debut.month, intervention.debut.day);
        if (!_interventions.containsKey(date)) {
          _interventions[date] = [];
        }
        _interventions[date]!.add(intervention);
      }
    });
  }

  Future<void> _loadTechnicianName() async {
    String name = await DatabaseHelper().getTechnicianName();
    setState(() {
      nomTechnicien = name; // Nom du technicien connecté
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Agenda'),
        actions: [
          // Affichage du nom du technicien à droite de l'AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(nomTechnicien),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar<Intervention>(
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              eventLoader: (day) {
                final DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                return _interventions[normalizedDay] ?? [];
              },
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _showAddInterventionDialog(context),
              child: Text('Ajouter une intervention'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 400,
              child: _buildInterventionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Déconnexion"),
                content: const Text("Voulez-vous vraiment vous déconnecter ?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    },
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Réinitialiser le statut de connexion du technicien
                      DatabaseHelper().resetTechnicianLoginStatus();

                      // Naviguer vers la page de connexion et supprimer toutes les routes précédentes
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: const Text("Déconnecter"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.logout),
        tooltip: 'Se déconnecter',
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildInterventionList() {

    void _removeIntervention(Intervention intervention) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmer la suppression"),
            content: const Text("Voulez-vous vraiment supprimer cette intervention ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue sans supprimer
                },
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  await DatabaseHelper().deleteIntervention(intervention);
                  setState(() {
                    _interventions[_selectedDay]?.remove(intervention);
                  });
                  _loadInterventionsForTechnician();
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue après la suppression
                },
                child: const Text("Supprimer"),
              ),
            ],
          );
        },
      );
    }

    final normalizedSelectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final interventionsForSelectedDay = _interventions[normalizedSelectedDay] ?? [];
    return ListView.builder(
      itemCount: interventionsForSelectedDay.length,
      itemBuilder: (context, index) {
        final intervention = interventionsForSelectedDay[index];
        return ListTile(
          title: Text(intervention.titre),
          subtitle: Text(
              'Client: ${intervention.client} - Statut: ${intervention.statut}\n'
                  'De ${formatDate(intervention.debut)} à ${formatDate(intervention.fin)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditInterventionDialog(context, intervention),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeIntervention(intervention),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _showSignatureDialog(context, intervention),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddInterventionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final clientController = TextEditingController();
    DateTime selectedDate = _selectedDay;
    TimeOfDay selectedStartTime = TimeOfDay(hour: 9, minute: 0);
    Duration selectedDuration = Duration(hours: 1); // Durée par défaut
    String? selectedFilePath;
    String comment = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter une intervention'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                  ListTile(
                    title: Text('Date de l\'intervention: ${formatDate(selectedDate)}'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text('Heure de début: ${selectedStartTime.format(context)}'),
                    onTap: () async {
                      final timePicked = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime,
                      );
                      if (timePicked != null) {
                        setState(() {
                          selectedStartTime = timePicked;
                        });
                      }
                    },
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durée de l\'intervention (en minutes)',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        selectedDuration = Duration(minutes: int.tryParse(value) ?? 60);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Ajouter un fichier'),
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          selectedFilePath = result.files.single.path;
                        });
                      }
                    },
                  ),
                  TextField(
                    onChanged: (value) {
                      comment = value;
                    },
                    decoration: InputDecoration(labelText: 'Commentaire'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final client = clientController.text;
                if (title.isNotEmpty && client.isNotEmpty) {
                  final startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedStartTime.hour, selectedStartTime.minute);
                  final endDateTime = startDateTime.add(selectedDuration);
                  _addIntervention(Intervention(
                    id: null,
                    titre: title,
                    client: client,
                    statut: 'En attente',
                    debut: startDateTime,
                    fin: endDateTime,
                    commentaire: comment,
                    fichierPath: selectedFilePath,
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ajouter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _addIntervention(Intervention intervention) async {
    int technicianId = await DatabaseHelper().getTechnicianId();
    int interventionId = await DatabaseHelper().addIntervention(technicianId, intervention);
    intervention.id = interventionId;
    setState(() {
      _interventions[_selectedDay]?.add(intervention);
    });
    _loadInterventionsForTechnician();
  }

  void _removeIntervention(Intervention intervention) async {
    await DatabaseHelper().deleteIntervention(intervention);
    setState(() {
      _interventions[_selectedDay]?.remove(intervention);
    });
    _loadInterventionsForTechnician();
  }

  void _showEditInterventionDialog(BuildContext context, Intervention intervention) {
    final titleController = TextEditingController(text: intervention.titre);
    final clientController = TextEditingController(text: intervention.client);
    final statusController = TextEditingController(text: intervention.statut);
    final durationController = TextEditingController(text: (intervention.fin.difference(intervention.debut).inMinutes).toString());
    final commentController = TextEditingController(text: intervention.commentaire);
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(intervention.debut);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier l\'intervention'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Titre'),
                  ),
                  TextField(
                    controller: clientController,
                    decoration: InputDecoration(labelText: 'Client'),
                  ),
                  TextField(
                    controller: statusController,
                    decoration: InputDecoration(labelText: 'Statut'),
                  ),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(labelText: 'Durée (en minutes)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(labelText: 'Commentaire'),
                  ),
                  ListTile(
                    title: Text('Heure de début: ${selectedStartTime.format(context)}'),
                    onTap: () async {
                      final timePicked = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime,
                      );
                      if (timePicked != null) {
                        setState(() {
                          selectedStartTime = timePicked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newTitle = titleController.text;
                final newClient = clientController.text;
                final newStatus = statusController.text;
                final newDuration = int.tryParse(durationController.text) ?? 60;
                final newComment = commentController.text;
                if (newTitle.isNotEmpty && newClient.isNotEmpty) {
                  final newStartDateTime = DateTime(intervention.debut.year, intervention.debut.month, intervention.debut.day, selectedStartTime.hour, selectedStartTime.minute);
                  final newEndDateTime = newStartDateTime.add(Duration(minutes: newDuration));
                  _updateIntervention(intervention.copyWith(
                    titre: newTitle,
                    client: newClient,
                    statut: newStatus,
                    debut: newStartDateTime,
                    fin: newEndDateTime,
                    commentaire: newComment,
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Mettre à jour'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _updateIntervention(Intervention intervention) async {
    await DatabaseHelper().updateIntervention(intervention);
    setState(() {
      final date = DateTime(intervention.debut.year, intervention.debut.month, intervention.debut.day);
      _interventions[date] = _interventions[date]?.map((i) => i.id == intervention.id ? intervention : i).toList() ?? [intervention];
    });
  }

  void _showSignatureDialog(BuildContext context, Intervention intervention) {
    final SignatureController _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Signature de l\'intervention'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: 300,
                color: Colors.grey[300],
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  _signatureController.clear();
                },
                child: Text('Effacer la signature'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  final signature = await _signatureController.toPngBytes();
                  if (signature != null) {
                    setState(() {
                      intervention.statut = 'Terminée';
                    });
                    await DatabaseHelper().updateStatutIntervention(intervention);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez signer avant de terminer')),
                  );
                }
              },
              child: Text('Confirmer la signature'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}


class Intervention {
   int? id;
   String titre;
   String client;
   String statut;
   DateTime debut;
   DateTime fin;
   String commentaire;
   String? fichierPath;

  Intervention({
    this.id,
    required this.titre,
    required this.client,
    required this.statut,
    required this.debut,
    required this.fin,
    required this.commentaire,
    this.fichierPath,
  });

Intervention copyWith({
  int? id,
  String? titre,
  String? client,
  String? statut,
  DateTime? debut,
  DateTime? fin,
  String? commentaire,
  String? fichierPath,
}) {
  return Intervention(
    id: id ?? this.id,
    titre: titre ?? this.titre,
    client: client ?? this.client,
    statut: statut ?? this.statut,
    debut: debut ?? this.debut,
    fin: fin ?? this.fin,
    commentaire: commentaire ?? this.commentaire,
    fichierPath: fichierPath ?? this.fichierPath,
  );
}
}
