import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/main.dart';

void main() {
  testWidgets('HomeGuardianApp smoke test mounts Dashboard successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HomeGuardianApp());
    await tester.pumpAndSettle();

    // Verify HomeGuardian app bar and dashboard elements are present
    expect(find.text('HomeGuardian'), findsOneWidget);
    expect(find.text('My Household'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Appliances'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
  });
}
