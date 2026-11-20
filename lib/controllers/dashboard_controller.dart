import '../observers/app_event_bus.dart';
import 'base_controller.dart';

/// MVC Controller for Centralized Dashboard
/// Observes Domain Events to automatically refresh statistics when tasks or appliances update
class DashboardController extends BaseController implements AppDomainObserver {
  int _pendingTasksCount = 0;
  int _expiringWarrantiesCount = 0;
  int _activeRemindersCount = 0;

  DashboardController() {
    AppEventBus.instance.subscribe(this);
  }

  int get pendingTasksCount => _pendingTasksCount;
  int get expiringWarrantiesCount => _expiringWarrantiesCount;
  int get activeRemindersCount => _activeRemindersCount;

  void updateMetrics({
    required int pendingTasks,
    required int expiringWarranties,
    required int activeReminders,
  }) {
    _pendingTasksCount = pendingTasks;
    _expiringWarrantiesCount = expiringWarranties;
    _activeRemindersCount = activeReminders;
    notifyListeners();
  }

  @override
  void onDomainEvent(AppEventType event, dynamic payload) {
    // React to domain events triggered across the app
    notifyListeners();
  }

  @override
  void dispose() {
    AppEventBus.instance.unsubscribe(this);
    super.dispose();
  }
}
