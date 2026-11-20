import 'app_event_bus.dart';

/// Observer Pattern Implementation: HouseholdObserver
/// Listens to household domain events and invokes customized callbacks.
class HouseholdObserver implements AppDomainObserver {
  final void Function(AppEventType event, dynamic payload) onEventReceived;

  HouseholdObserver({required this.onEventReceived});

  @override
  void onDomainEvent(AppEventType event, dynamic payload) {
    onEventReceived(event, payload);
  }
}

