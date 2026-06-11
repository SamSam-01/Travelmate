import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/widgets/home_carousel.dart';

void main() {
  group('Activity', () {
    test('toInsertJson maps properties correctly', () {
      const activity = Activity(
        id: 'test-id',
        title: 'Beach',
        subtitle: 'Plage du Prado',
        badge: 'Nature',
        tone: HomeCarouselTone.water,
        icon: Icons.water_outlined,
        sortOrder: 5,
      );

      final json = activity.toInsertJson();

      expect(json['id'], 'test-id');
      expect(json['title'], 'Beach');
      expect(json['subtitle'], 'Plage du Prado');
      expect(json['badge'], 'Nature');
      expect(json['tone'], 'water');
      expect(json['icon_key'], 'water_outlined');
      expect(json['sort_order'], 5);
    });

    test('toInsertJson handles empty id by omitting it or keeping it empty if we want to rely on DB default', () {
      const activity = Activity(
        id: '',
        title: 'New Place',
        subtitle: 'No Address',
        badge: 'City',
        tone: HomeCarouselTone.city,
        icon: Icons.location_city_outlined,
        sortOrder: 0,
      );

      final json = activity.toInsertJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['title'], 'New Place');
    });
  });
}
