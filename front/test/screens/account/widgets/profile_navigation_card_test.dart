import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/screens/account/widgets/profile_sections.dart';

void main() {
  testWidgets('should render navigation card content when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileNavigationCard(
            icon: Icons.people_outline,
            title: 'Amis',
            subtitle: 'Voir le reseau',
            value: '12',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Amis'), findsOneWidget);
    expect(find.text('Voir le reseau'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
