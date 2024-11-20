import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_agenda/agenda_app.dart';


void main() {
    testWidgets('Test ajout de signature dans une intervention', (WidgetTester tester) async {
        await tester.pumpWidget(AgendaApp());

        expect(find.text('Ajouter une intervention'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsNothing);

        await tester.tap(find.text('Ajouter une intervention'));
        await tester.pumpAndSettle();

        expect(find.text('Titre de l\'intervention'), findsOneWidget);
        expect(find.text('Client'), findsOneWidget);

        await tester.enterText(find.byType(TextField).at(0), 'Test Intervention');
        await tester.enterText(find.byType(TextField).at(1), 'Test Client');

        await tester.tap(find.text('Ajouter'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check).first);
        await tester.pumpAndSettle();

        expect(find.text('Signature de l\'intervention'), findsOneWidget);
    });
}
