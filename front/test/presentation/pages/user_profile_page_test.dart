import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/presentation/pages/user_profile_page.dart';
import 'package:front/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(UserProfile profile) {
    return MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: UserProfilePage(profile: profile),
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
}
