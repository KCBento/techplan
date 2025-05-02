import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mon_agenda/agenda_app.dart';
import 'package:mon_agenda/connexion.dart';
import 'package:mon_agenda/database.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
    setUpAll(() async {
        // Initialisation de la base de données pour utiliser FFI
        databaseFactory = databaseFactoryFfi;
    });

    testWidgets('Test affichage des champs de connexion', (WidgetTester tester) async {
        // Charger la page de connexion
        await tester.pumpWidget(MaterialApp(home: Connexion()));

        // Vérifier la présence des champs Identifiant et Mot de passe
        expect(find.text('Identifiant'), findsOneWidget);
        expect(find.text('Mot De Passe'), findsOneWidget);

        // Vérifier la présence du bouton Valider
        expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('Test validation des champs vides', (WidgetTester tester) async {
        // Charger la page de connexion
        await tester.pumpWidget(MaterialApp(home: Connexion()));

        // Appuyer sur le bouton Valider sans remplir les champs
        await tester.tap(find.text('Valider'));
        await tester.pump();

        // Vérifier les messages d'erreur
        expect(find.text('Veuillez compléter ce champ'), findsNWidgets(2));
    });

    testWidgets('Test saisie des champs de connexion', (WidgetTester tester) async {
        // Charger la page de connexion
        await tester.pumpWidget(MaterialApp(home: Connexion()));

        // Saisir un identifiant
        await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
        // Saisir un mot de passe
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // Vérifier que les valeurs sont bien saisies
        expect(find.text('testuser'), findsOneWidget);
        // Vérifier que le mot de passe est masqué
        final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));

        // On accède au contrôleur du champ de texte pour vérifier la valeur
        final textController = passwordField.controller;

        // Vérifier que le texte est bien saisi dans le champ de mot de passe
        expect(textController?.text, equals('password123'));

        // Vérifier que le mot de passe est masqué en cherchant le widget EditableText
        final editableText = tester.widget<EditableText>(find.byType(EditableText).at(1));

        // Vérifie que le champ de mot de passe est bien masqué
        expect(editableText.obscureText, isTrue);
    });

    testWidgets('Test visibilité du mot de passe', (WidgetTester tester) async {
        // Charger la page de connexion
        await tester.pumpWidget(MaterialApp(home: Connexion()));

        // Saisir un mot de passe
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // Vérifier que le mot de passe est masqué
        final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));
        final textController = passwordField.controller;
        expect(textController?.text, 'password123');

        // Vérifier que le texte est masqué (obscureText = true)
        final editableText = tester.widget<EditableText>(find.byType(EditableText).at(1));
        expect(editableText.obscureText, isTrue);

        // Activer la visibilité du mot de passe
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Vérifier que le mot de passe est maintenant visible (obscureText = false)
        final updatedEditableText = tester.widget<EditableText>(find.byType(EditableText).at(1));
        expect(updatedEditableText.obscureText, isFalse);

        // Vérifier que le mot de passe est visible maintenant
        expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Test connexion avec identifiants incorrects', (WidgetTester tester) async {
        // Charger la page de connexion
        await tester.pumpWidget(MaterialApp(home: Connexion()));

        // Saisir un identifiant et un mot de passe incorrects
        await tester.enterText(find.byType(TextFormField).at(0), 'wronguser');
        await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

        // Appuyer sur le bouton Valider
        await tester.tap(find.text('Valider'));
        await tester.pumpAndSettle();  // Attendre que l'interface se mette à jour

        // Vérifier que le Snackbar avec le message d'erreur est affiché
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Identifiant ou mot de passe incorrect'), findsOneWidget);
    });



    testWidgets('Test connexion avec identifiants corrects', (WidgetTester tester) async {
        // Créer une instance simulée
        final mockDbHelper = MockDatabaseHelper();

        // Simuler la méthode checkConnection
        when(mockDbHelper.checkConnection('Bouzid', 'admin'))
            .thenAnswer((_) async => true);

        // Simuler la page de connexion en utilisant mockDbHelper
        await tester.pumpWidget(
            const MaterialApp(
                home: Connexion(),
            ),
        );

        // Tester la logique
        await tester.enterText(find.byType(TextFormField).at(0), 'Bouzid');
        await tester.enterText(find.byType(TextFormField).at(1), 'admin');

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Vérifier que le message de succès apparaît
        expect(find.text('Connexion réussie'), findsOneWidget);

        // Vérifier la navigation vers la page d'accueil
        expect(find.byType(AgendaPage), findsOneWidget);
    });
}
