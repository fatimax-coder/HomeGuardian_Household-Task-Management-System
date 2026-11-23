import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/config/app_routes.dart';
import 'package:home_guardian/config/app_theme.dart';
import 'package:home_guardian/views/splash/splash_view.dart';

void main() {
  Widget buildTestableSplash({VoidCallback? onTimeout}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: SplashView(onTimeout: onTimeout ?? () {}),
      routes: {
        AppRoutes.authGate: (_) => const Scaffold(body: Text('AuthGateScreen')),
      },
    );
  }

  group('SplashView Flow & Premium Feature Verification', () {
    testWidgets('Renders HomeGuardian logo, app name, and tagline',
        (tester) async {
      await tester.pumpWidget(buildTestableSplash());

      expect(find.text('HomeGuardian'), findsOneWidget);
      expect(
          find.text('A Smarter Way to Manage Your Home.'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('Renders all 4 bottom feature highlights', (tester) async {
      await tester.pumpWidget(buildTestableSplash());

      expect(find.text('Secure & Reliable'), findsOneWidget);
      expect(find.text('Manage Your Home'), findsOneWidget);
      expect(find.text('Get Timely Reminders'), findsOneWidget);
      expect(find.text('Keep Family Connected'), findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('Displays promotional card with heading and Special Offer tag',
        (tester) async {
      await tester.pumpWidget(buildTestableSplash());

      expect(find.text('Special Offer'), findsOneWidget);
      expect(find.text('Smart Home, Better Life.'), findsOneWidget);
      expect(
          find.text('Discover features that make home management easier.'),
          findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('Close button dismisses promotional card without navigating',
        (tester) async {
      bool navigated = false;
      await tester.pumpWidget(buildTestableSplash(
        onTimeout: () => navigated = true,
      ));

      expect(find.text('Special Offer'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Card dismissed
      expect(find.text('Special Offer'), findsNothing);
      // Navigation not triggered
      expect(navigated, isFalse);

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('Learn More button opens informative dialog', (tester) async {
      bool navigated = false;
      await tester.pumpWidget(buildTestableSplash(
        onTimeout: () => navigated = true,
      ));

      // Tap Learn More
      await tester.tap(find.text('Learn More'));
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.text('Got It'), findsOneWidget);
      expect(navigated, isFalse);

      // Close dialog
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 11));
    });

    testWidgets('10-second countdown decrements and triggers navigation at 0',
        (tester) async {
      bool timeoutCalled = false;
      await tester.pumpWidget(buildTestableSplash(
        onTimeout: () => timeoutCalled = true,
      ));

      // Initial state: 10
      expect(find.text('10'), findsOneWidget);
      expect(timeoutCalled, isFalse);

      // Advance 1 second -> 9
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('9'), findsOneWidget);
      expect(timeoutCalled, isFalse);

      // Advance 4 more seconds -> 5
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('5'), findsOneWidget);
      expect(timeoutCalled, isFalse);

      // Advance remaining 5 seconds -> triggers timeout
      await tester.pump(const Duration(seconds: 5));
      expect(timeoutCalled, isTrue);
    });

    testWidgets('Tapping anywhere skips countdown and navigates immediately',
        (tester) async {
      bool tappedToNavigate = false;
      await tester.pumpWidget(buildTestableSplash(
        onTimeout: () => tappedToNavigate = true,
      ));

      expect(find.text('10'), findsOneWidget);
      expect(tappedToNavigate, isFalse);

      // Tap anywhere
      await tester.tap(find.text('A Smarter Way to Manage Your Home.'));
      await tester.pump();

      expect(tappedToNavigate, isTrue);
    });
  });
}

