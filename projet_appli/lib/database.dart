import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      CREATE TABLE Signature (
        id_Signature INTEGER PRIMARY KEY,
        date_Signature TEXT
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
        id_Connexion INTEGER,
        id_Signature INTEGER,
        id_Agenda INTEGER,
        FOREIGN KEY(id_Connexion) REFERENCES Connexion(id_Connexion),
        FOREIGN KEY(id_Signature) REFERENCES Signature(id_Signature),
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
        Lien TEXT,
        Type_Fichier TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Intervention (
        id_Intervention INTEGER PRIMARY KEY,
        Titre TEXT,
        Date TEXT,
        Heure TEXT,
        Statut TEXT,
        id_Description INTEGER,
        id_Signature INTEGER,
        id_Fichier INTEGER,
        FOREIGN KEY(id_Description) REFERENCES Description(id_Description),
        FOREIGN KEY(id_Signature) REFERENCES Signature(id_Signature),
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

    // Insertion des données dans Signature
    await db.execute('''
      INSERT INTO Signature (date_Signature)
      VALUES ('2024-01-01'),
             ('2024-02-01'),
             ('2024-03-01');
    ''');

    // Insertion des données dans Agenda
    await db.execute('''
      INSERT INTO Agenda (id_Agenda)
      VALUES (1), (2), (3);
    ''');

    // Insertion des données dans Technicien
    await db.execute('''
      INSERT INTO Technicien (Nom, Prenom, id_Connexion, id_Signature, id_Agenda)
      VALUES ('Decrouy', 'Aristide', 1, 1, 1),
             ('Ghlamallah', 'Bouzid', 2, 2, 2),
             ('Bourguet', 'Lucas', 3, 3, 3);
    ''');

    // Insertion des données dans Commentaire
    await db.execute('''
      INSERT INTO Description (contenu)
      VALUES ('Description 1'), ('Description 2'), ('Description 3');
    ''');

    // Insertion des données dans Intervention
    await db.execute('''
      INSERT INTO Intervention (Titre, Date, Heure, Statut, id_Description, id_Signature, id_Fichier)
      VALUES ('Intervention 1', '2024-05-01', '10:00', 'En cours', 1, 1, 1),
             ('Intervention 2', '2024-06-01', '11:00', 'Terminé', 2, 2, 2),
             ('Intervention 3', '2024-07-01', '09:00', 'En attente', 3, 3, 3);
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
  Future<List<Map<String, dynamic>>> obtenirTechniciens() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT Technicien.Nom, Technicien.Prenom, Connexion.Login, Connexion.Mot_De_Passe
      FROM Technicien
      INNER JOIN Connexion ON Technicien.id_Connexion = Connexion.id_Connexion
      
    ''');
  }

  Future<bool> verifierIdentifiants(String login, String motDePasse) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT * FROM Connexion
    WHERE Login = ? AND Mot_De_Passe = ?
    ''',
      [login, motDePasse],
    );
    return result.isNotEmpty; // Retourne true si un utilisateur est trouvé
  }



}
