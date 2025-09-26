import 'package:front/screens/home/home_screen.dart';

import 'commons.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      navigatorKey: navigatorKey,

      ///Screen names used from file screens.dart
      initialRoute: Screens.home,
      routes: {Screens.home: (_) => const HomeScreen()},
    );
  }
}
