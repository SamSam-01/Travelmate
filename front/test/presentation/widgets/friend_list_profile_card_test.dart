import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/widgets/friend_list_profile_card.dart';

void main() {
  testWidgets('should render friend profile card when friend is provided', (
    WidgetTester tester,
  ) async {
    const profile = UserProfile(
      id: 'friend-1',
      username: 'leo',
      displayName: 'Leo Martin',
      avatarUrl: null,
      isPrivate: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FriendListProfileCard(
            profile: profile,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Leo Martin'), findsOneWidget);
    expect(find.text('@leo'), findsOneWidget);
    expect(find.text('Profil public'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
