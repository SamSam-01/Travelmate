import 'package:front/screens/account/account_page.dart';
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
      home: const HomePage(),
      navigatorKey: navigatorKey,
      initialRoute: Screens.home,
      routes: {
        Screens.home: (_) => const HomePage(),
        Screens.login: (_) => const LoginPage(),
        Screens.profile: (_) => const AccountPage(),
        '/account': (_) => const AccountPage(),
      },
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
