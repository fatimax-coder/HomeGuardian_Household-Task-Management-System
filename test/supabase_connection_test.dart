import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_guardian/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SupabaseService connects and initializes client with provided credentials', () async {
    final service = SupabaseService.instance;

    await service.initialize(
      url: 'https://oqpxnvkfjpyjoboghyhs.supabase.co/rest/v1/',
      publishableKey: 'sb_publishable_aRXVdcjhXjQ0d7_Hi3ziOg_gjNNuzH4',
    );

    expect(service.isInitialized, isTrue);
    expect(service.client, isNotNull);
    expect(service.client.auth, isNotNull);
    expect(service.client.rest, isNotNull);
  });
}
