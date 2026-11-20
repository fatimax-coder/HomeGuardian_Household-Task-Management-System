import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../main_scaffold_view.dart';
import 'login_view.dart';

/// Authentication Gate Widget
/// Inspects authenticated session state to display MainScaffoldView or LoginView accordingly
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.isAuthenticated) {
      return const MainScaffoldView();
    } else {
      return const LoginView();
    }
  }
}
