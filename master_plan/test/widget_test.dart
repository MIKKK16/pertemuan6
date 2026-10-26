import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:master_plan/main.dart';

void main() {
  testWidgets('Menambah plan baru tampil di daftar', (WidgetTester tester) async {
    await tester.pumpWidget(const MasterPlanApp());

    expect(find.text('Anda belum memiliki rencana apapun.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Belajar Flutter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('0 out of 0 tasks'), findsOneWidget);
  });
}