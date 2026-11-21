import 'package:flutter_test/flutter_test.dart';
import 'package:home_guardian/controllers/appliance_controller.dart';
import 'package:home_guardian/controllers/auth_controller.dart';
import 'package:home_guardian/controllers/household_controller.dart';
import 'package:home_guardian/controllers/reminder_controller.dart';
import 'package:home_guardian/controllers/task_controller.dart';
import 'package:home_guardian/factories/reminder_factory.dart';
import 'package:home_guardian/factories/task_factory.dart';
import 'package:home_guardian/models/appliance.dart';
import 'package:home_guardian/models/household.dart';
import 'package:home_guardian/models/household_member.dart';
import 'package:home_guardian/models/maintenance_record.dart';
import 'package:home_guardian/models/reminder.dart';
import 'package:home_guardian/models/task.dart';
import 'package:home_guardian/models/user_profile.dart';
import 'package:home_guardian/observers/app_event_bus.dart';
import 'package:home_guardian/observers/household_observer.dart';
import 'package:home_guardian/repositories/appliance_repository.dart';
import 'package:home_guardian/repositories/auth_repository.dart';
import 'package:home_guardian/repositories/household_repository.dart';
import 'package:home_guardian/repositories/reminder_repository.dart';
import 'package:home_guardian/repositories/task_repository.dart';
import 'package:home_guardian/services/notification_service.dart';
import 'package:home_guardian/services/supabase_service.dart';
import 'package:home_guardian/strategies/reminder_filter_strategy.dart';
import 'package:home_guardian/strategies/task_sort_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -----------------------------------------------------------------------------
// Mock Repositories for End-to-End System Integration Testing
// -----------------------------------------------------------------------------

class FullMockAuthRepository implements IAuthRepository {
  UserProfile? _currentProfile;
  User? _currentUser;
  bool _authenticated = false;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState>? get authStateChanges => null;

  @override
  Future<UserProfile?> getCurrentProfile() async => _currentProfile;

  @override
  Future<UserProfile> signIn({required String email, required String password}) async {
    _authenticated = true;
    _currentProfile = UserProfile(
      id: 'usr-100',
      fullName: 'Dr Sis',
      email: email,
      createdAt: DateTime.now(),
    );
    return _currentProfile!;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _authenticated = true;
    _currentProfile = UserProfile(
      id: 'usr-100',
      fullName: fullName,
      email: email,
      createdAt: DateTime.now(),
    );
    return SignUpResult(
      profile: _currentProfile,
      requiresEmailConfirmation: false,
      message: 'Signup successful',
    );
  }

  @override
  Future<void> signOut() async {
    _authenticated = false;
    _currentProfile = null;
    _currentUser = null;
  }
}

class FullMockHouseholdRepository implements IHouseholdRepository {
  final List<Household> households = [];
  final Map<String, List<HouseholdMember>> members = {};

  @override
  Future<List<Household>> getUserHouseholds() async => List.from(households);

  @override
  Future<Household> createHousehold({required String name}) async {
    final code = HouseholdRepository.generateInviteCode();
    final h = Household(
      id: 'h-${households.length + 1}',
      name: name,
      inviteCode: code,
      createdBy: 'usr-100',
      createdAt: DateTime.now(),
    );
    households.add(h);
    members[h.id] = [
      HouseholdMember(
        id: 'mem-admin',
        householdId: h.id,
        userId: 'usr-100',
        memberName: 'Dr Sis',
        role: 'admin',
      ),
    ];
    return h;
  }

  @override
  Future<Household> joinHousehold({required String inviteCode}) async {
    final h = households.firstWhere(
      (element) => element.inviteCode == inviteCode,
      orElse: () => throw Exception('Invalid invite code: $inviteCode'),
    );
    final list = members[h.id] ?? [];
    list.add(HouseholdMember(
      id: 'mem-${list.length + 1}',
      householdId: h.id,
      userId: 'usr-guest',
      memberName: 'Guest User',
      role: 'member',
    ));
    members[h.id] = list;
    return h;
  }

  @override
  Future<List<HouseholdMember>> getHouseholdMembers(String householdId) async {
    return List.from(members[householdId] ?? []);
  }

  @override
  Future<HouseholdMember> addMemberByName({
    required String householdId,
    required String name,
  }) async {
    final m = HouseholdMember(
      id: 'mem-unlinked-${DateTime.now().millisecondsSinceEpoch}',
      householdId: householdId,
      userId: null,
      memberName: name,
      role: 'member',
    );
    members[householdId] = [...(members[householdId] ?? []), m];
    return m;
  }

  @override
  Future<void> removeMember(String memberId) async {
    for (final key in members.keys) {
      members[key]?.removeWhere((m) => m.id == memberId);
    }
  }
}

class FullMockTaskRepository implements ITaskRepository {
  final List<Task> tasks = [];

  @override
  Future<List<Task>> getTasks(String householdId) async {
    return tasks.where((t) => t.householdId == householdId).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final created = task.copyWith(id: 'tsk-${tasks.length + 1}');
    tasks.insert(0, created);
    return created;
  }

  @override
  Future<void> updateTask(Task task) async {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) tasks[idx] = task;
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      tasks[idx] = tasks[idx].copyWith(isCompleted: isCompleted);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    tasks.removeWhere((t) => t.id == taskId);
  }
}

class FullMockApplianceRepository implements IApplianceRepository {
  final List<Appliance> appliances = [];
  final Map<String, List<MaintenanceRecord>> records = {};

  @override
  Future<List<Appliance>> getAppliances(String householdId) async {
    return appliances.where((a) => a.householdId == householdId).toList();
  }

  @override
  Future<Appliance> createAppliance(Appliance appliance) async {
    final created = appliance.copyWith(id: 'app-${appliances.length + 1}');
    appliances.add(created);
    return created;
  }

  @override
  Future<void> updateAppliance(Appliance appliance) async {
    final idx = appliances.indexWhere((a) => a.id == appliance.id);
    if (idx != -1) appliances[idx] = appliance;
  }

  @override
  Future<void> deleteAppliance(String applianceId) async {
    appliances.removeWhere((a) => a.id == applianceId);
    records.remove(applianceId);
  }

  @override
  Future<List<MaintenanceRecord>> getMaintenanceRecords(String applianceId) async {
    return List.from(records[applianceId] ?? []);
  }

  @override
  Future<MaintenanceRecord> addMaintenanceRecord(MaintenanceRecord record) async {
    final created = record.copyWith(id: 'rec-${DateTime.now().millisecondsSinceEpoch}');
    final list = records[record.applianceId] ?? [];
    records[record.applianceId] = [created, ...list];
    return created;
  }
}

class FullMockReminderRepository implements IReminderRepository {
  final List<Reminder> reminders = [];

  @override
  Future<List<Reminder>> getReminders(String householdId) async {
    return reminders.where((r) => r.householdId == householdId).toList();
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final created = reminder.copyWith(id: 'rem-${reminders.length + 1}');
    reminders.add(created);
    return created;
  }

  @override
  Future<void> dismissReminder(String reminderId) async {
    final idx = reminders.indexWhere((r) => r.id == reminderId);
    if (idx != -1) {
      reminders[idx] = reminders[idx].copyWith(isDismissed: true);
    }
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    reminders.removeWhere((r) => r.id == reminderId);
  }
}

// -----------------------------------------------------------------------------
// Master End-to-End Test Suite
// -----------------------------------------------------------------------------

void main() {
  group('Full System End-to-End Integration & Quality Assurance Audit', () {
    late FullMockAuthRepository authRepo;
    late AuthController authController;

    late FullMockHouseholdRepository householdRepo;
    late HouseholdController householdController;

    late FullMockTaskRepository taskRepo;
    late TaskController taskController;

    late FullMockApplianceRepository applianceRepo;
    late ApplianceController applianceController;

    late FullMockReminderRepository reminderRepo;
    late ReminderController reminderController;

    setUp(() {
      authRepo = FullMockAuthRepository();
      authController = AuthController(authRepo);

      householdRepo = FullMockHouseholdRepository();
      householdController = HouseholdController(householdRepo);

      taskRepo = FullMockTaskRepository();
      taskController = TaskController(taskRepo);

      applianceRepo = FullMockApplianceRepository();
      applianceController = ApplianceController(applianceRepo);

      reminderRepo = FullMockReminderRepository();
      reminderController = ReminderController(reminderRepo);
    });

    // -------------------------------------------------------------------------
    // 1. Authentication & Profile Creation Audit
    // -------------------------------------------------------------------------
    test('Audit 1: User Signup, Login, and Session Persistence', () async {
      expect(authController.isAuthenticated, isFalse);

      // Sign up
      final signupResult = await authController.signUp(
        email: 'test@homeguardian.com',
        password: 'Password123!',
        fullName: 'Dr Sis',
      );
      expect(signupResult, isNotNull);
      expect(signupResult!.profile, isNotNull);
      expect(signupResult.requiresEmailConfirmation, isFalse);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentProfile?.fullName, 'Dr Sis');
      expect(authController.currentProfile?.email, 'test@homeguardian.com');

      // Sign out
      await authController.signOut();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentProfile, isNull);

      // Sign in
      final loginSuccess = await authController.signIn(
        'test@homeguardian.com',
        'Password123!',
      );
      expect(loginSuccess, isTrue);
      expect(authController.isAuthenticated, isTrue);
    });

    // -------------------------------------------------------------------------
    // 2. Household Lifecycle, 6-Char Code & Role-Based Access Audit
    // -------------------------------------------------------------------------
    test('Audit 2: Household Creation, Invite Code, and Member Roles', () async {
      // Create household
      final created = await householdController.createHousehold('Maplewood Residence');
      expect(created, isTrue);
      final activeHousehold = householdController.selectedHousehold;
      expect(activeHousehold, isNotNull);
      expect(activeHousehold?.name, 'Maplewood Residence');

      // Verify 6-character uppercase alphanumeric code
      final inviteCode = activeHousehold!.inviteCode;
      expect(inviteCode.length, 6);
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(inviteCode), isTrue);

      // Verify creator is Admin
      expect(householdController.isCurrentAdmin, isTrue);
      expect(householdController.currentUserRole, 'Admin');
      expect(householdController.totalMembersCount, 1);

      // Admin adds an unlinked family member (e.g., kid without account)
      final addedChild = await householdController.addFamilyMember('Tommy Sis');
      expect(addedChild, isTrue);
      expect(householdController.totalMembersCount, 2);
      final tommy = householdController.members.firstWhere((m) => m.memberName == 'Tommy Sis');
      expect(tommy.hasAccount, isFalse);
      expect(tommy.isAdmin, isFalse);

      // Guest user joins using the 6-character code
      final guestController = HouseholdController(householdRepo);
      final guestJoined = await guestController.joinHousehold(inviteCode);
      expect(guestJoined, isTrue);
      expect(guestController.selectedHousehold?.name, 'Maplewood Residence');
      expect(guestController.members.any((m) => m.memberName == 'Guest User' && !m.isAdmin), isTrue);
    });

    // -------------------------------------------------------------------------
    // 3. Tasks Lifecycle, Strategy Sorting & Assignment Audit
    // -------------------------------------------------------------------------
    test('Audit 3: Task CRUD, Assignment, Priorities & Strategy Sorting', () async {
      await householdController.createHousehold('Falcon Crest');
      final hid = householdController.selectedHousehold!.id;
      final adminMember = householdController.members.first;

      // Add tasks with different priorities and due dates
      final now = DateTime.now();
      await taskController.addTask(Task(
        id: '',
        householdId: hid,
        title: 'Deep clean kitchen oven',
        priority: 'high',
        assignedMemberId: adminMember.id,
        dueDate: now.add(const Duration(days: 1)),
      ));
      await taskController.addTask(Task(
        id: '',
        householdId: hid,
        title: 'Water front yard garden',
        priority: 'low',
        dueDate: now.add(const Duration(days: 4)),
      ));
      await taskController.addTask(Task(
        id: '',
        householdId: hid,
        title: 'Check furnace air filter',
        priority: 'medium',
        dueDate: now.add(const Duration(days: 2)),
      ));

      expect(taskController.totalTasksCount, 3);
      expect(taskController.pendingTasksCount, 3);
      expect(taskController.completedTasksCount, 0);
      expect(taskController.highPriorityCount, 1);
      expect(taskController.mediumPriorityCount, 1);
      expect(taskController.lowPriorityCount, 1);

      // Strategy Pattern: Verify Sort By Priority
      taskController.setSortStrategy(SortByPriorityStrategy());
      expect(taskController.tasks.first.priority, 'high');
      expect(taskController.tasks.last.priority, 'low');

      // Strategy Pattern: Verify Sort By Due Date
      taskController.setSortStrategy(SortByDueDateStrategy());
      expect(taskController.tasks.first.title, 'Deep clean kitchen oven');

      // Toggle completion status
      final ovenTask = taskController.tasks.first;
      await taskController.toggleTaskStatus(ovenTask.id, true);
      expect(taskController.completedTasksCount, 1);
      expect(taskController.pendingTasksCount, 2);

      // Delete task
      final deleted = await taskController.deleteTask(ovenTask.id);
      expect(deleted, isTrue);
      expect(taskController.totalTasksCount, 2);
    });

    // -------------------------------------------------------------------------
    // 4. Appliances & Warranty Expiry Audit
    // -------------------------------------------------------------------------
    test('Audit 4: Appliance Registry, Warranty Countdown & Expiry Calculations', () async {
      await householdController.createHousehold('Ocean View Villa');
      final hid = householdController.selectedHousehold!.id;
      final now = DateTime.now();

      // Appliance 1: Active warranty (purchased 2 months ago, 12 mo warranty)
      final activeFridge = Appliance(
        id: '',
        householdId: hid,
        name: 'Samsung French Door Refrigerator',
        brand: 'Samsung',
        model: 'RF28T',
        purchaseDate: DateTime(now.year, now.month - 2, now.day),
        warrantyMonths: 12,
      );
      await applianceController.addAppliance(activeFridge);

      // Appliance 2: Expiring Soon (< 30 days) (purchased 11.5 months ago, 12 mo warranty)
      final expiringWasher = Appliance(
        id: '',
        householdId: hid,
        name: 'LG TurboWash Washing Machine',
        brand: 'LG',
        model: 'WM4000',
        purchaseDate: DateTime(now.year, now.month - 11, now.day - 16),
        warrantyMonths: 12,
      );
      await applianceController.addAppliance(expiringWasher);

      // Appliance 3: Expired warranty (purchased 2 years ago)
      final expiredMicrowave = Appliance(
        id: '',
        householdId: hid,
        name: 'Panasonic Inverter Microwave',
        brand: 'Panasonic',
        purchaseDate: DateTime(now.year - 2, 1, 1),
        warrantyMonths: 12,
      );
      await applianceController.addAppliance(expiredMicrowave);

      expect(applianceController.totalAppliancesCount, 3);
      expect(applianceController.expiringWarrantiesCount, 1);

      final appliances = applianceController.appliances;
      final fridge = appliances.firstWhere((a) => a.name.contains('Samsung'));
      expect(fridge.isWarrantyActive, isTrue);
      expect(fridge.warrantyStatus, contains('Active'));

      final washer = appliances.firstWhere((a) => a.name.contains('LG'));
      expect(washer.isWarrantyActive, isTrue);
      expect(washer.warrantyStatus, contains('Expiring Soon'));

      final microwave = appliances.firstWhere((a) => a.name.contains('Panasonic'));
      expect(microwave.isWarrantyActive, isFalse);
      expect(microwave.warrantyStatus, 'Expired');
    });

    // -------------------------------------------------------------------------
    // 5. Maintenance Records & Real Expense Calculation Audit
    // -------------------------------------------------------------------------
    test('Audit 5: Maintenance Service Logs & Non-Fabricated Expense Calculation', () async {
      await householdController.createHousehold('Pinecrest House');
      final hid = householdController.selectedHousehold!.id;

      final app = await applianceRepo.createAppliance(Appliance(
        id: '',
        householdId: hid,
        name: 'Carrier Central AC',
      ));
      await applianceController.fetchAppliances(hid);

      // Empty state verification: no maintenance recorded yet
      expect(applianceController.hasMaintenanceRecords, isFalse);
      expect(applianceController.totalMaintenanceCost, 0.0);

      // Add real maintenance records
      final now = DateTime.now();
      await applianceController.addMaintenanceRecord(MaintenanceRecord(
        id: '',
        applianceId: app.id,
        serviceDate: now,
        description: 'Compressor capacitor replacement',
        cost: 175.50,
        serviceProvider: 'Carrier Care Express',
      ));

      await applianceController.addMaintenanceRecord(MaintenanceRecord(
        id: '',
        applianceId: app.id,
        serviceDate: DateTime(now.year, now.month - 1, 15),
        description: 'Annual seasonal tuneup and refrigerant top-up',
        cost: 120.00,
        serviceProvider: 'CoolWave HVAC',
      ));

      expect(applianceController.hasMaintenanceRecords, isTrue);
      expect(applianceController.totalMaintenanceCost, 295.50);

      final monthly = applianceController.monthlyExpenses;
      expect(monthly.values.any((cost) => cost > 0), isTrue);
    });

    // -------------------------------------------------------------------------
    // 6. Reminders Lifecycle & ReminderFactory Audit
    // -------------------------------------------------------------------------
    test('Audit 6: ReminderFactory Alert Generation, Strategy Filtering & Dismissal', () async {
      await householdController.createHousehold('Cedar Ridge');
      final hid = householdController.selectedHousehold!.id;

      // Factory Pattern: Create Bill reminder
      final bill = ReminderFactory.create(
        householdId: hid,
        type: ReminderType.bill,
        title: 'Quarterly Water & Sewage Bill',
        reminderDate: DateTime.now().add(const Duration(days: 5)),
        description: '\$84.20 due via direct debit',
      );
      await reminderController.addReminder(bill);

      // Factory Pattern: Create Warranty Alert
      final warranty = ReminderFactory.createWarrantyAlert(
        householdId: hid,
        applianceName: 'Bosch Dishwasher',
        warrantyExpiryDate: DateTime.now().add(const Duration(days: 14)),
        applianceId: 'app-bosch-1',
      );
      await reminderController.addReminder(warranty);

      // Factory Pattern: Create Maintenance Alert (Overdue)
      final maint = ReminderFactory.createMaintenanceAlert(
        householdId: hid,
        applianceName: 'Water Heater',
        serviceDate: DateTime.now().subtract(const Duration(days: 2)),
        applianceId: 'app-heater-1',
      );
      await reminderController.addReminder(maint);

      expect(reminderController.totalCount, 3);
      expect(reminderController.activeCount, 3);
      expect(reminderController.urgentCount, 1); // 1 is overdue

      // Strategy Pattern: Filter Warranty Only
      reminderController.setFilterStrategy(WarrantyRemindersStrategy());
      expect(reminderController.reminders.length, 1);
      expect(reminderController.reminders.first.type, ReminderType.warranty);

      // Strategy Pattern: Filter Urgent Only
      reminderController.setFilterStrategy(UrgentRemindersStrategy());
      expect(reminderController.reminders.length, 1);
      expect(reminderController.reminders.first.title, contains('Scheduled Service'));

      // Dismiss reminder
      final overdueRemId = reminderController.reminders.first.id;
      await reminderController.dismissReminder(overdueRemId);
      expect(reminderController.urgentCount, 0);

      // Delete reminder
      final deleted = await reminderController.deleteReminder(overdueRemId);
      expect(deleted, isTrue);
      expect(reminderController.totalCount, 2);
    });

    // -------------------------------------------------------------------------
    // 7. Design Pattern Foundation Audit (6 Required Patterns)
    // -------------------------------------------------------------------------
    test('Audit 7: Design Patterns Verification (Singleton, Factory, Strategy, Observer, MVC, Repository)', () {
      // 1. Singleton Pattern: Identical instances
      expect(identical(SupabaseService.instance, SupabaseService.instance), isTrue);
      expect(identical(NotificationService.instance, NotificationService.instance), isTrue);
      expect(identical(AppEventBus.instance, AppEventBus.instance), isTrue);

      // 2. Factory Pattern: TaskFactory template generation
      final routineChore = TaskFactory.createACFilterCheck('h-test');
      expect(routineChore.title, 'Inspect & Clean AC Filters');
      expect(routineChore.priority, 'medium');

      // 3. Strategy Pattern: Swappable algorithms
      final sortStrategy = SortByPriorityStrategy();
      expect(sortStrategy.name, 'Priority');

      // 4. Observer Pattern: Event subscription & notification
      final bus = AppEventBus.instance;
      AppEventType? receivedEvent;
      dynamic receivedPayload;

      final observer = HouseholdObserver(
        onEventReceived: (event, payload) {
          receivedEvent = event;
          receivedPayload = payload;
        },
      );

      bus.subscribe(observer);
      bus.notify(AppEventType.taskCreated, 'test-task-payload');

      expect(receivedEvent, AppEventType.taskCreated);
      expect(receivedPayload, 'test-task-payload');

      bus.unsubscribe(observer);

      // 5. MVC + Repository Pattern: Controllers decouple UI from Supabase storage
      expect(taskController, isA<TaskController>());
      expect(taskRepo, isA<ITaskRepository>());
    });
  });
}
