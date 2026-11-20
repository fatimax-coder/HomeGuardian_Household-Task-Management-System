import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../dashboard/dashboard_view.dart';
import 'login_view.dart';

/// Authentication Gate Widget
/// Inspects authenticated session state to display Dashboard or LoginView accordingly
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.isAuthenticated) {
      return const DashboardView();
    } else {
      return const LoginView();
    }
  }
}
