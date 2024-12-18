import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'agenda_app.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'intervention_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> resetTechnicianLoginStatus() async {
    Database db = await database;

    await db.rawUpdate(
        'UPDATE Technicien SET estConnecte = 0 WHERE estConnecte = 1'
    );
  }

  Future _onCreate(Database db, int version) async {
    // Création des tables
    await db.execute('''
      CREATE TABLE Connexion (
        id_Connexion INTEGER PRIMARY KEY,
        Login TEXT,
        Mot_De_Passe TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Agenda (
        id_Agenda INTEGER PRIMARY KEY
      );
    ''');

    await db.execute('''
      CREATE TABLE Technicien (
        id_Technicien INTEGER PRIMARY KEY,
        Nom TEXT,
        Prenom TEXT,
        estConnecte INTEGER DEFAULT 0,
        id_Connexion INTEGER,
        id_Agenda INTEGER,
        FOREIGN KEY(id_Connexion) REFERENCES Connexion(id_Connexion),
        FOREIGN KEY(id_Agenda) REFERENCES Agenda(id_Agenda)
      );
    ''');

    await db.execute('''
      CREATE TABLE Description (
        id_Description INTEGER PRIMARY KEY,
        contenu TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Fichier (
        id_Fichier INTEGER PRIMARY KEY,
        Lien TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Intervention (
        id_Intervention INTEGER PRIMARY KEY,
        Titre TEXT,
        Date Date,
        Heure TEXT,
        Statut TEXT,
        id_Description INTEGER,
        id_Fichier INTEGER,
        Client VARCHAR(100),
        FOREIGN KEY(id_Description) REFERENCES Description(id_Description),
        FOREIGN KEY(id_Fichier) REFERENCES Fichier(id_Fichier)
      );
    ''');

    await db.execute('''
      CREATE TABLE Contenir (
        id_Intervention INTEGER,
        id_Agenda INTEGER,
        PRIMARY KEY(id_Intervention, id_Agenda),
        FOREIGN KEY(id_Intervention) REFERENCES Intervention(id_Intervention),
        FOREIGN KEY(id_Agenda) REFERENCES Agenda(id_Agenda)
      );
    ''');

    await insertInitialData(db);
  }

  Future insertInitialData(Database db) async {
    // Insertion des données dans Connexion
    await db.execute('''
      INSERT INTO Connexion (Login, Mot_De_Passe)
      VALUES ('Aristide', 'admin'),
             ('Bouzid', 'admin'),
             ('Lucas', 'admin');
    ''');

    // Insertion des données dans Agenda
    await db.execute('''
      INSERT INTO Agenda (id_Agenda)
      VALUES (1), (2), (3);
    ''');

    // Insertion des données dans Technicien
    await db.execute('''
      INSERT INTO Technicien (Nom, Prenom, id_Connexion, id_Agenda)
      VALUES ('Decrouy', 'Aristide', 1, 1),
             ('Ghlamallah', 'Bouzid', 2, 2),
             ('Bourguet', 'Lucas', 3, 3);
    ''');

    // Insertion des données dans Commentaire
    await db.execute('''
      INSERT INTO Description (contenu)
      VALUES ('Description 1'), ('Description 2'), ('Description 3');
    ''');

    // Insertion des données dans Intervention
    await db.execute('''
      INSERT INTO Intervention (Titre, Date, Heure, Statut, id_Description, id_Fichier, Client)
      VALUES ('Intervention 1', '2024-11-01', '10:00', 'En cours', 1, 1, 'Paul'),
             ('Intervention 2', '2024-06-01', '11:00', 'Terminé', 2, 2, 'Lorenzo'),
             ('Intervention 3', '2024-07-01', '09:00', 'En attente', 3, 3, 'Valentin');
    ''');

    // Insertion des données dans Contenir
    await db.execute('''
      INSERT INTO Contenir (id_Intervention, id_Agenda)
      VALUES (1, 1),
             (2, 2),
             (3, 3);
    ''');
  }


  // Obtenir les techniciens avec leurs connexions
  Future<List<Map<String, dynamic>>> getTechnicians() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT Technicien.Nom, Technicien.Prenom, Connexion.Login, Connexion.Mot_De_Passe
      FROM Technicien
      INNER JOIN Connexion ON Technicien.id_Connexion = Connexion.id_Connexion
      
    ''');
  }

  Future<bool> checkConnection(String login, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT * FROM Connexion
    WHERE Login = ? AND Mot_De_Passe = ?
    ''',
      [login, password],
    );
    return result.isNotEmpty; // Retourne true si un utilisateur est trouvé
  }

  Future<List<Intervention>> fetchInterventionsForTechnician(int technicianId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT Intervention.id_Intervention, Intervention.Titre, Intervention.Date, Intervention.Heure, Intervention.Statut, Description.contenu, Fichier.lien, Intervention.Client  
    FROM Intervention
    INNER JOIN Contenir ON Contenir.id_Intervention = Intervention.id_Intervention
    INNER JOIN Agenda ON Agenda.id_Agenda = Contenir.id_Agenda
    INNER JOIN Technicien ON Technicien.id_Agenda = Agenda.id_Agenda
    LEFT JOIN Description ON Description.id_Description = Intervention.id_Description
    LEFT JOIN Fichier ON Fichier.id_Fichier = Intervention.id_Fichier
    WHERE Technicien.id_Technicien = ?;
    ''',
      [technicianId],
    );

    List<Intervention> interventions = result.map((map) {
      return Intervention(
        id: map['id_Intervention'],
        titre: map['Titre'],
        client: map['Client'],
        statut: map['Statut'],
        debut: DateTime.parse(map['Date'] + ' ' + map['Heure']), // Fusionne la date et l'heure
        fin: DateTime.parse(map['Date'] + ' ' + map['Heure']).add(Duration(hours: 1)), // Exemple d'ajout d'une heure pour la fin
        commentaire: map['contenu'] ?? 'Pas de description',
        fichierPath: map['lien'],
      );
    }).toList();

    return interventions;
  }

  Future<void> updateTechnicianLoginStatus(int technicianId) async {
    Database db = await database;

    // Connecter le technicien spécifique
    await db.rawUpdate(
      'UPDATE Technicien SET estConnecte = 1 WHERE id_Technicien = ?',
      [technicianId],
    );
  }


  Future<int> getTechnicianId() async {
    Database db = await database; // Accès à votre instance SQLite

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT id_Technicien FROM Technicien WHERE estConnecte = ? LIMIT 1',
        [1]
    );

    if (result.isNotEmpty) {
      return result.first['id_Technicien'] as int; // Retourne l'ID du technicien connecté
    } else {
      throw Exception('Technicien non trouvé ou non connecté.');
    }
  }

  Future<int> getTechnicianIdByCredentials(String username, String password) async {
    Database db = await database;

    // Requête pour vérifier les identifiants
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT id_Technicien FROM Technicien
      INNER JOIN Connexion ON Connexion.id_Connexion = Technicien.id_Connexion
      WHERE Login = ? AND Mot_De_Passe = ? 
      LIMIT 1
      ''',
      [username, password]
    );

    // Si un technicien est trouvé, retourner son ID
    return result.first['id_Technicien'] as int;


  }

  Future<String> getTechnicianName() async {
    Database db = await database;

    // Requête pour vérifier les identifiants
    List<Map<String, dynamic>> result = await db.rawQuery(
        '''
      SELECT Prenom, Nom FROM Technicien
      WHERE estConnecte = ?
      LIMIT 1
      ''',
        [1]
    );

    String prenom = result[0]['Prenom'];
    String nom = result[0]['Nom'];
    return '$prenom $nom'; // Retourne le prénom et le nom combinés
  }

  Future<int> addIntervention(int technicianId, Intervention intervention) async {
    Database db = await database;

    int? descriptionId;
    if (intervention.commentaire.isNotEmpty) {
      descriptionId = await db.rawInsert('''
      INSERT INTO Description (contenu)
      VALUES (?)
      ''',
          [intervention.commentaire]
      );
    }



    int? fichierId;
    if (intervention.fichierPath != null && intervention.fichierPath!.isNotEmpty) {
      fichierId = await db.rawInsert('''
      INSERT INTO Fichier (Lien)
      VALUES (?)
      ''',
          [intervention.fichierPath.toString()]
      );
    }

    String date = '${intervention.debut.year}-${intervention.debut.month.toString().padLeft(2, '0')}-${intervention.debut.day.toString().padLeft(2, '0')}';
    String heure = '${intervention.debut.hour.toString().padLeft(2, '0')}:${intervention.debut.minute.toString().padLeft(2, '0')}';
    int idIntervention = await db.rawInsert('''
      INSERT INTO Intervention (Titre, Date, Heure, Statut, id_Description, id_Fichier, Client)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        [intervention.titre,
          date,
          heure,
          intervention.statut,
          descriptionId,
          fichierId,
          intervention.client]
    );

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT id_Agenda FROM Technicien WHERE id_Technicien = ?',
        [technicianId]
    );

    int idAgenda = result.first['id_Agenda'];

    await db.rawInsert('''
    INSERT INTO Contenir (id_Intervention, id_Agenda)
    VALUES (?, ?)
    ''',
      [idIntervention, idAgenda]
    );

    return idIntervention;
  }

  Future<void> updateIntervention(Intervention intervention) async {
    Database db = await database;

    // Formatage de la date et de l'heure
    String date = '${intervention.debut.year}-${intervention.debut.month.toString().padLeft(2, '0')}-${intervention.debut.day.toString().padLeft(2, '0')}';
    String heure = '${intervention.debut.hour.toString().padLeft(2, '0')}:${intervention.debut.minute.toString().padLeft(2, '0')}';

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT id_Description, id_Fichier FROM Intervention WHERE id_Intervention = ?',
        [intervention.id]
    );
    int? descriptionId = result.first['id_Description'];
    int? fichierId = result.first['id_Fichier'];

    if (intervention.commentaire.isNotEmpty && descriptionId == null) {
      descriptionId = await db.rawInsert('''
      INSERT INTO Description (contenu)
      VALUES (?)
      ''',
          [intervention.commentaire]
      );
    }

    if (intervention.fichierPath != null && intervention.fichierPath!.isNotEmpty && fichierId == null) {
      fichierId = await db.rawInsert('''
      INSERT INTO Fichier (Lien)
      VALUES (?)
      ''',
          [intervention.fichierPath.toString()]
      );
    }

    // Exécution de la mise à jour
    await db.update(
      'Intervention', // Nom de la table
      {
        'Titre': intervention.titre,
        'Date': date,
        'Heure': heure,
        'Statut': intervention.statut,
        'id_Description': descriptionId,
        'id_Fichier': fichierId,
        'Client': intervention.client,
      },
      where: 'id_Intervention = ?', // Clause WHERE pour cibler une ligne
      whereArgs: [intervention.id], // Arguments pour WHERE
    );
  }

  Future<void> deleteIntervention(Intervention intervention) async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT id_Description, id_Fichier FROM Intervention WHERE id_Intervention = ?',
        [intervention.id]
    );
    int? descriptionId = result.first['id_Description'];
    int? fichierId = result.first['id_Fichier'];

    if (descriptionId != null) {
      await db.delete(
        'Description',
        where: 'id_Description = ?',
        whereArgs: [descriptionId],
      );
    }

    if (fichierId != null) {
      await db.delete(
        'Fichier',
        where: 'id_Fichier = ?',
        whereArgs: [fichierId],
      );
    }

    await db.delete(
      'Contenir',
      where: 'id_Intervention = ?',
      whereArgs: [intervention.id],
    );

    await db.delete(
      'Intervention',
      where: 'id_Intervention = ?',
      whereArgs: [intervention.id],
    );
  }

  Future<void> updateStatutIntervention(Intervention intervention) async {
    Database db = await database;
    // Exécution de la mise à jour
    await db.update(
      'Intervention', // Nom de la table
      {
        'Statut': intervention.statut,
      },
      where: 'id_Intervention = ?', // Clause WHERE pour cibler une ligne
      whereArgs: [intervention.id], // Arguments pour WHERE
    );
  }




}
