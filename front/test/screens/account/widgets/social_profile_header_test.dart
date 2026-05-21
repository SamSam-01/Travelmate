import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/entities/user_profile.dart';
import 'package:front/screens/account/widgets/social_profile_header.dart';

void main() {
  testWidgets('should render social profile header details and actions', (
    WidgetTester tester,
  ) async {
    const profile = UserProfile(
      id: 'user-1',
      username: 'samuel',
      displayName: 'Samuel Blard',
      avatarUrl: null,
      isPrivate: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialProfileHeader(
            profile: profile,
            friendsLabel: 'Friends',
            requestsLabel: 'Requests',
            visibilityLabel: 'Visibility',
            publicLabel: 'Public profile',
            privateLabel: 'Private profile',
            searchActionLabel: 'Search',
            editActionLabel: 'Edit',
            friendCount: 12,
            pendingRequestCount: 3,
            onSearchPressed: () {},
            onEditPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Samuel Blard'), findsOneWidget);
    expect(find.text('@samuel'), findsOneWidget);
    expect(find.text('Public profile'), findsNWidgets(2));
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });
}
