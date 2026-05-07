import 'package:flutter/material.dart';
import 'package:front/screens/app/authenticated_app_shell.dart';
import 'package:front/screens/home/home_page.dart';
import 'package:front/screens/login/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'commons.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRAZER',
      theme: lightTheme,
      darkTheme: darkTheme,
      navigatorKey: navigatorKey,
      initialRoute: Screens.home,
      routes: {
        Screens.home: (_) => const HomePage(),
        Screens.login: (_) => const LoginPage(),
        Screens.outings: (_) => const OutingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Screens.app || settings.name == Screens.profile) {
          final initialTab = _resolveInitialTab(
            settings.name,
            settings.arguments,
          );

          return MaterialPageRoute(
            builder: (_) => AuthenticatedAppShell(initialTab: initialTab),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}

AppShellTab _resolveInitialTab(String? routeName, Object? arguments) {
  if (arguments is AppShellTab) {
    return arguments;
  }

  if (routeName == Screens.profile) {
    return AppShellTab.profile;
  }

  return AppShellTab.home;
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
