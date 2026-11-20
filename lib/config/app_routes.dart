import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/tasks/task_list_view.dart';
import '../views/tasks/task_form_view.dart';
import '../views/appliances/appliance_list_view.dart';
import '../views/appliances/appliance_detail_view.dart';
import '../views/reminders/reminder_list_view.dart';
import '../views/household/household_view.dart';
import '../views/household/members_view.dart';

/// Centralized route declarations for HomeGuardian
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String taskForm = '/task-form';
  static const String appliances = '/appliances';
  static const String applianceDetail = '/appliance-detail';
  static const String reminders = '/reminders';
  static const String household = '/household';
  static const String members = '/members';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const DashboardView(),
        login: (context) => const LoginView(),
        signup: (context) => const SignupView(),
        dashboard: (context) => const DashboardView(),
        tasks: (context) => const TaskListView(),
        taskForm: (context) => const TaskFormView(),
        appliances: (context) => const ApplianceListView(),
        applianceDetail: (context) => const ApplianceDetailView(),
        reminders: (context) => const ReminderListView(),
        household: (context) => const HouseholdView(),
        members: (context) => const MembersView(),
      };
}

