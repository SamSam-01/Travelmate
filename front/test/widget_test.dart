import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/screens.dart';
import 'package:front/screens/app/authenticated_app_shell.dart';
import 'package:front/screens/home/home_page.dart';
import 'package:front/screens/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('CRAZER welcome page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('CRAZER'), findsOneWidget);
    expect(find.text('Explorer sans compte'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('guest can open the login page from home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('CRAZER'), findsOneWidget);
  });

  testWidgets('authenticated shell shows all tabs by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        home: const AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Maps'), findsOneWidget);
    expect(find.text('Amis'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('authenticated shell switches to profile tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        home: const AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsWidgets);
    expect(find.text('Connexion requise'), findsOneWidget);
  });

  testWidgets('home page with session CTA opens profile tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
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
    expect(find.text('Connexion requise'), findsOneWidget);
  });

  testWidgets('authenticated shell opens maps tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        home: const AuthenticatedAppShell(profileRequiresSession: false),
      ),
    );

    await tester.tap(find.text('Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Maps'), findsWidgets);
    expect(find.text('Token Mapbox manquant'), findsOneWidget);
  });

  testWidgets('profile tab shows login required state without session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
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

    expect(find.text('Connexion requise'), findsOneWidget);
  });
}

Widget _buildLocalizedApp({
  Widget? home,
  String? initialRoute,
  Map<String, WidgetBuilder>? routes,
  RouteFactory? onGenerateRoute,
}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
      initialRoute: initialRoute,
      routes: routes ?? const <String, WidgetBuilder>{},
      onGenerateRoute: onGenerateRoute,
    ),
  );
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
