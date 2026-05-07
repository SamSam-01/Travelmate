import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/utils/planned_outing_relations.dart';
import 'package:front/widgets/home_carousel.dart';

void main() {
  test(
    'should build outings from foreign key relations and filter by user',
    () {
      final outings = buildPlannedOutingsFromRelations(
        outingRows: const <Map<String, dynamic>>[
          {
            'id': 'outing-1',
            'title': 'Sortie FK A',
            'created_at': '2026-05-07T10:00:00Z',
          },
          {
            'id': 'outing-2',
            'title': 'Sortie FK B',
            'created_at': '2026-05-07T11:00:00Z',
          },
        ],
        usersByOutingId: {
          'outing-1': const [PlannedOutingUser(id: 'user-1', name: 'Alice')],
          'outing-2': const [PlannedOutingUser(id: 'user-2', name: 'Bob')],
        },
        activitiesByOutingId: {
          'outing-1': [
            PlannedOutingActivity.fromActivity(
              Activity(
                id: 'activity-1',
                title: 'Petit-déjeuner',
                subtitle: 'Au port',
                badge: 'Matin',
                tone: HomeCarouselTone.food,
                icon: Icons.restaurant_outlined,
                sortOrder: 1,
              ),
              time: '08:30',
            ),
          ],
          'outing-2': [
            PlannedOutingActivity.fromActivity(
              Activity(
                id: 'activity-2',
                title: 'Randonnée',
                subtitle: 'Colline',
                badge: 'Nature',
                tone: HomeCarouselTone.nature,
                icon: Icons.terrain_outlined,
                sortOrder: 1,
              ),
              time: '09:00',
            ),
          ],
        },
        currentUserId: 'user-1',
      );

      expect(outings, hasLength(1));
      expect(outings.single.id, 'outing-1');
      expect(outings.single.users.single.name, 'Alice');
      expect(outings.single.activities.single.activityId, 'activity-1');
      expect(outings.single.activities.single.title, 'Petit-déjeuner');
    },
  );
}
