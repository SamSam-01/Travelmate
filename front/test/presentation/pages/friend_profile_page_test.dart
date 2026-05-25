import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/presentation/pages/friend_profile_page.dart';

void main() {
  testWidgets('should render friend profile details when page opens', (
    WidgetTester tester,
  ) async {
    const profile = UserProfile(
      id: 'friend-1',
      username: 'leo',
      displayName: 'Leo Martin',
      avatarUrl: null,
      isPrivate: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FriendProfilePage(profile: profile),
      ),
    );

    expect(find.text('Leo Martin'), findsWidgets);
    expect(find.text('@leo'), findsWidgets);
    expect(find.text('Profil privé'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });
}
