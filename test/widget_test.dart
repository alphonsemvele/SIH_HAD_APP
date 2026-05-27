import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/main.dart';

void main() {
  testWidgets('App boots without crashing', (tester) async {
    await tester.pumpWidget(const PatientApp());
    // Vérifie que le splash s'affiche (titre "HAD Patient" du splash screen)
    expect(find.text('HAD Patient'), findsOneWidget);
  });
}
