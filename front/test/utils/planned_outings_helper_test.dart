import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/utils/planned_outings_helper.dart';
import 'package:front/widgets/home_carousel.dart';

void main() {
  test('should prefer planned outings when the current user is present', () {
    final plannedOutings = [
      PlannedOuting(
        id: '1',
        title: 'Sortie A',
        users: const [PlannedOutingUser(id: 'u1', name: 'Alice')],
        activities: const [
          PlannedOutingActivity(title: 'Départ', time: '08:30'),
        ],
      ),
      PlannedOuting(
        id: '2',
        title: 'Sortie B',
        users: const [PlannedOutingUser(id: 'u1', name: 'Alice')],
        activities: const [
          PlannedOutingActivity(title: 'Randonnée', time: '10:00'),
        ],
      ),
    ];

    final activities = [
      Activity(
        id: 'a1',
        title: 'Activité planifiée',
        subtitle: 'fallback',
        badge: 'Planifié',
        tone: HomeCarouselTone.planned,
        icon: Icons.event_available_outlined,
        sortOrder: 1,
      ),
    ];

    final items = resolvePlannedOutingCarouselItems(
      plannedOutings: plannedOutings,
      activities: activities,
      userId: 'u1',
    );

    expect(items, hasLength(2));
    expect(items.first.title, 'Sortie A');
    expect(items.last.title, 'Sortie B');
  });

  test('should ignore outings where the current user is absent', () {
    final filtered = filterPlannedOutingsForUser(
      plannedOutings: [
        PlannedOuting(
          id: '1',
          title: 'Sortie A',
          users: const [PlannedOutingUser(id: 'u1', name: 'Alice')],
          activities: const [],
        ),
        PlannedOuting(
          id: '2',
          title: 'Sortie B',
          users: const [PlannedOutingUser(id: 'u2', name: 'Bob')],
          activities: const [],
        ),
      ],
      userId: 'u1',
    );

    expect(filtered, hasLength(1));
    expect(filtered.single.title, 'Sortie A');
  });

  test(
    'should fall back to planned activities when no planned outings exist',
    () {
      final items = resolvePlannedOutingCarouselItems(
        plannedOutings: const [],
        activities: [
          Activity(
            id: 'a1',
            title: 'Activité planifiée',
            subtitle: 'fallback',
            badge: 'Planifié',
            tone: HomeCarouselTone.planned,
            icon: Icons.event_available_outlined,
            sortOrder: 1,
          ),
          Activity(
            id: 'a2',
            title: 'Activité normale',
            subtitle: 'fallback',
            badge: 'Ville',
            tone: HomeCarouselTone.city,
            icon: Icons.location_city_outlined,
            sortOrder: 2,
          ),
        ],
        userId: 'u1',
      );

      expect(items, hasLength(1));
      expect(items.single.title, 'Activité planifiée');
    },
  );
}
