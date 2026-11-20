/// Domain Event Types for Observer Pattern
enum AppEventType {
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  applianceCreated,
  applianceUpdated,
  maintenanceLogged,
  householdChanged,
  memberUpdated,
}

/// Observer Pattern Interface
abstract class AppDomainObserver {
  void onDomainEvent(AppEventType event, dynamic payload);
}

/// Observer Pattern Implementation: AppEventBus (Singleton Subject)
/// Manages list of subscribers and notifies them when household domain events occur.
class AppEventBus {
  AppEventBus._internal();

  static final AppEventBus instance = AppEventBus._internal();

  final List<AppDomainObserver> _observers = [];

  void subscribe(AppDomainObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  void unsubscribe(AppDomainObserver observer) {
    _observers.remove(observer);
  }

  void notify(AppEventType event, [dynamic payload]) {
    for (final observer in List.unmodifiable(_observers)) {
      try {
        observer.onDomainEvent(event, payload);
      } catch (_) {
        // Observers should not break the notification pipeline
      }
    }
  }

  int get observerCount => _observers.length;
}

