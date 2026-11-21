import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/main.dart';

void main() {
  testWidgets('HomeGuardianApp mounts AuthGate and renders LoginView for unauthenticated users',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HomeGuardianApp());
    await tester.pumpAndSettle();

    // Verify Login elements are rendered by default when no session exists
    expect(find.text('HomeGuardian'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
