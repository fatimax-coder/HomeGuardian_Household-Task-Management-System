import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_constants.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'controllers/appliance_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/household_controller.dart';
import 'controllers/reminder_controller.dart';
import 'controllers/task_controller.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Singleton Services
  await SupabaseService.instance.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabasePublishableKey,
  );

  await NotificationService.instance.initialize();

  runApp(const HomeGuardianApp());
}

/// Root Application Widget configured with MultiProvider & Warm Minimalist Theme
class HomeGuardianApp extends StatelessWidget {
  final String? initialRoute;
  const HomeGuardianApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HouseholdController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => ApplianceController()),
        ChangeNotifierProvider(create: (_) => ReminderController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute ?? AppRoutes.initial,
        routes: AppRoutes.routes,
      ),
    );
  }
}
