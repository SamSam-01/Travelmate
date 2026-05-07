import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:front/pages/account_page.dart';
import 'package:front/pages/home_page.dart';
import 'package:front/pages/login_page.dart';
import 'package:front/pages/reset_password_page.dart';
import 'package:front/pages/welcome_page.dart';
import 'package:front/theme/crazer_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
const _passwordResetRedirectUrl = String.fromEnvironment(
  'PASSWORD_RESET_REDIRECT_URL',
);
final isMapboxSupported = !kIsWeb;

String? get passwordResetRedirectUrl {
  if (_passwordResetRedirectUrl.isNotEmpty) {
    return _passwordResetRedirectUrl;
  }

  if (!kIsWeb) return null;

  final baseUri = Uri.base;
  final path = baseUri.path.isEmpty ? '/' : baseUri.path;
  return '${baseUri.origin}$path?mode=reset-password';
}

bool get isPasswordRecoveryLaunch {
  if (!kIsWeb) return false;

  final uri = Uri.base;
  if (uri.queryParameters['mode'] == 'reset-password') {
    return true;
  }

  if (uri.queryParameters['type'] == 'recovery') {
    return true;
  }

  final fragment = uri.fragment;
  if (fragment == '/reset-password' ||
      fragment.startsWith('/reset-password?') ||
      fragment.contains('type=recovery')) {
    return true;
  }

  return false;
}

String get initialRouteName {
  if (isPasswordRecoveryLaunch) {
    return '/reset-password';
  }

  return supabase.auth.currentSession == null ? '/welcome' : '/home';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isMapboxSupported && mapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    runApp(const CrazerConfigErrorApp());
    return;
  }

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;
  late bool _isPasswordRecovery;

  @override
  void initState() {
    super.initState();
    _isPasswordRecovery = isPasswordRecoveryLaunch;
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      _handleAuthStateChange,
    );
  }

  void _handleAuthStateChange(AuthState data) {
    if (!mounted) return;

    switch (data.event) {
      case AuthChangeEvent.passwordRecovery:
        setState(() {
          _isPasswordRecovery = true;
        });
      case AuthChangeEvent.userUpdated:
        setState(() {
          _isPasswordRecovery = false;
        });
      case AuthChangeEvent.signedOut:
        setState(() {
          _isPasswordRecovery = false;
        });
      default:
        break;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Widget _buildHome() {
    if (_isPasswordRecovery) {
      return const ResetPasswordPage();
    }

    return supabase.auth.currentSession == null
        ? const WelcomePage()
        : const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRAZER',
      theme: CrazerTheme.dark(),
      home: _buildHome(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/account': (context) => const AccountPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
      },
    );
  }
}

class CrazerConfigErrorApp extends StatelessWidget {
  const CrazerConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRAZER',
      theme: CrazerTheme.dark(),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Configuration Supabase manquante. Lancez l\'app avec SUPABASE_URL et SUPABASE_ANON_KEY en dart-define.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
