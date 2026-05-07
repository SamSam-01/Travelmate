import 'package:flutter/services.dart';
import 'package:front/commons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

/// Used to initialize any services or other important things for the app
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// StatusBar color and brightness as per design.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY dart defines');
  }

  if (mapboxAccessToken.isNotEmpty) {
    // Some platforms (desktop) may not register the Mapbox plugin implementation,
    // causing a missing channel handler error. Guard this call so the app
    // doesn't crash when the plugin isn't available (e.g. Linux desktop).
    try {
      MapboxOptions.setAccessToken(mapboxAccessToken);
    } catch (e, st) {
      // Avoid crashing the app if the platform doesn't support Mapbox plugin.
      // Log for debugging purposes.
      // ignore: avoid_print
      print('Mapbox setAccessToken failed: $e\n$st');
    }
  }

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
}
