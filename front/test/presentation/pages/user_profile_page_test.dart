import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/presentation/pages/user_profile_page.dart';
import 'package:front/presentation/providers/outing_providers.dart';
import 'package:front/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(UserProfile profile, {List<PlannedOuting>? outings}) {
    return ProviderScope(
      overrides: [
        sharedOutingsProvider(profile.id).overrideWith((ref) => outings ?? []),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UserProfilePage(profile: profile),
      ),
    );
  }

  testWidgets('should display profile information correctly when display name is present', (tester) async {
    const profile = UserProfile(
      id: '1',
      username: 'testuser',
      displayName: 'Test User',
      avatarUrl: null,
      isPrivate: false,
    );

    await tester.pumpWidget(createWidgetUnderTest(profile));
    await tester.pumpAndSettle();

    expect(find.text('testuser'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Aucune activité en cours avec cette personne.'), findsOneWidget);
  });

  testWidgets('should display profile information correctly when display name is null', (tester) async {
    const profile = UserProfile(
      id: '2',
      username: 'anotheruser',
      displayName: null,
      avatarUrl: null,
      isPrivate: false,
    );

    await tester.pumpWidget(createWidgetUnderTest(profile));
    await tester.pumpAndSettle();

    expect(find.text('anotheruser'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
  
  testWidgets('should display shared outings', (tester) async {
    const profile = UserProfile(
      id: '1',
      username: 'testuser',
      displayName: 'Test User',
      avatarUrl: null,
      isPrivate: false,
    );

    final outings = [
      PlannedOuting(
        id: 'o1',
        title: 'Trip to Paris',
        users: const [],
        activities: const [],
        createdAt: DateTime(2023),
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(profile, outings: outings));
    await tester.pumpAndSettle();

    expect(find.text('Trip to Paris'), findsOneWidget);
  });
}
