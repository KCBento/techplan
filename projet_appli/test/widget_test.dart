import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_appli/main.dart'; // Assurez-vous que le chemin est correct

void main() {
  testWidgets('Agenda app has a title and adds interventions', (WidgetTester tester) async {
    // Construire l'application
    await tester.pumpWidget(AgendaApp());

    // Vérifier que le titre de l'application est présent
    expect(find.text('Mon Agenda'), findsOneWidget);

    // Vérifier que le bouton d'ajout d'intervention est présent
    expect(find.text('Ajouter une intervention'), findsOneWidget);

    // Appuyer sur le bouton pour ajouter une intervention
    await tester.tap(find.text('Ajouter une intervention'));
    await tester.pump(); // Rebuild

    // Saisir un titre d'intervention
    await tester.enterText(find.byType(TextField).at(0), 'Mon intervention');

    // Saisir un client
    await tester.enterText(find.byType(TextField).at(1), 'Client A');

    // Appuyer sur le bouton pour ajouter l'intervention
    await tester.tap(find.text('Ajouter'));
    await tester.pump(); // Rebuild

    // Vérifier que l'intervention a été ajoutée
    expect(find.text('Mon intervention'), findsOneWidget);
    expect(find.text('Client A'), findsOneWidget);
  });
}
