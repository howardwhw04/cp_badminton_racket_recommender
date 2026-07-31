import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badmimton_racket_recommender/main.dart';
import 'package:badmimton_racket_recommender/providers/app_state.dart';
import 'package:badmimton_racket_recommender/config/supabase_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{}; // Return empty map
    }
    return null;
  });

  testWidgets('App gates navigation and shows login screen when not logged in', (WidgetTester tester) async {
    // Initialize Supabase for test environment
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
      ),
    );

    // Build our app wrapped in AppState provider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MyApp(),
      ),
    );

    // Verify that the login screen is displayed by looking for its unique header text
    expect(find.text('ELITE PRECISION'), findsOneWidget);
    
    // Verify that the home dashboard (e.g. welcome card text) is not displayed
    expect(find.text('RACKETBASE DASHBOARD'), findsNothing);
  });
}
