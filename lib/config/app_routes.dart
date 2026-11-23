import 'package:flutter/material.dart';
import '../views/auth/auth_gate.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/main_scaffold_view.dart';
import '../views/splash/splash_view.dart';
import '../views/tasks/task_list_view.dart';
import '../views/tasks/task_form_view.dart';
import '../views/appliances/appliance_list_view.dart';
import '../views/appliances/appliance_form_view.dart';
import '../views/appliances/appliance_detail_view.dart';
import '../views/reminders/reminder_list_view.dart';
import '../views/household/household_view.dart';
import '../views/household/members_view.dart';
import '../views/profile/profile_view.dart';

/// Centralized route declarations for HomeGuardian
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String splash = '/splash';
  static const String authGate = '/auth-gate';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String taskForm = '/task-form';
  static const String appliances = '/appliances';
  static const String applianceForm = '/appliance-form';
  static const String applianceDetail = '/appliance-detail';
  static const String reminders = '/reminders';
  static const String household = '/household';
  static const String members = '/members';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SplashView(),
        splash: (context) => const SplashView(),
        authGate: (context) => const AuthGate(),
        login: (context) => const LoginView(),
        signup: (context) => const SignupView(),
        main: (context) => const MainScaffoldView(),
        dashboard: (context) => const MainScaffoldView(initialIndex: 0),
        tasks: (context) => const TaskListView(),
        taskForm: (context) => const TaskFormView(),
        appliances: (context) => const ApplianceListView(),
        applianceForm: (context) => const ApplianceFormView(),
        applianceDetail: (context) => const ApplianceDetailView(),
        reminders: (context) => const ReminderListView(),
        household: (context) => const HouseholdView(),
        members: (context) => const MembersView(),
        profile: (context) => const ProfileView(),
      };
}
