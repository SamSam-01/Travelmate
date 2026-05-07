import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/screens/app/authenticated_app_shell.dart';
import 'package:front/screens/home/home_page.dart';
import 'package:front/screens/login/login_page.dart';
import 'package:front/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:front/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('CRAZER welcome page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('CRAZER'), findsOneWidget);
    expect(find.text('Explorer sans compte'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('guest can open the login page from home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Pas de compte ? Créer un compte'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('authenticated shell shows home tab by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.byType(AuthenticatedAppShell), findsOneWidget);
  });

  testWidgets('authenticated shell switches to profile tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('User Name'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('home page with session CTA opens profile tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: Screens.home,
        routes: {
          Screens.home: (_) => const HomePage(hasSessionOverride: true),
          Screens.login: (_) => const LoginPage(),
        },
        onGenerateRoute: (settings) =>
            _onGenerateRoute(settings, profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Accéder à mon compte'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('authenticated shell opens maps tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Maps'), findsWidgets);
    expect(find.text('Token Mapbox manquant'), findsOneWidget);
  });

  testWidgets('profile tab exposes the sign out action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: Screens.app,
        routes: {
          Screens.home: (_) => const HomePage(),
          Screens.login: (_) => const LoginPage(),
        },
        onGenerateRoute: (settings) =>
            _onGenerateRoute(settings, profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Sign Out'), findsOneWidget);

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
  });
}

Route<dynamic>? _onGenerateRoute(
  RouteSettings settings, {
  bool profileRequiresSession = true,
}) {
  if (settings.name == Screens.app || settings.name == Screens.profile) {
    final initialTab = settings.arguments is AppShellTab
        ? settings.arguments as AppShellTab
        : settings.name == Screens.profile
        ? AppShellTab.profile
        : AppShellTab.home;

    return MaterialPageRoute(
      builder: (_) => AuthenticatedAppShell(
        initialTab: initialTab,
        profileRequiresSession: profileRequiresSession,
      ),
      settings: settings,
    );
  }

  return null;
}
