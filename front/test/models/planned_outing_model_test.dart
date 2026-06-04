import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/planned_outing_model.dart';

void main() {
  test('should parse Google Place activity when place id is provided', () {
    final activity = PlannedOutingActivity.fromJson(const <String, dynamic>{
      'google_place_id': 'ChIJN1t_tDeuEmsRUsoyG83frY4',
      'google_place_name': 'Le Jardin de l\'État',
      'time': '09:00',
    });

    expect(activity.googlePlaceId, 'ChIJN1t_tDeuEmsRUsoyG83frY4');
    expect(activity.googlePlaceName, 'Le Jardin de l\'État');
    expect(activity.title, 'Le Jardin de l\'État');
    expect(activity.time, '09:00');
    expect(activity.icon, Icons.event_available_outlined);
  });

  test('should serialize Google Place activity source fields', () {
    final activity = PlannedOutingActivity.fromGooglePlace(
      placeId: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
      title: 'Le Jardin de l\'État',
      subtitle: 'Rue de Paris, Saint-Denis',
      time: '',
    );

    final json = activity.toJson();

    expect(json['activity_id'], '');
    expect(json['google_place_id'], 'ChIJN1t_tDeuEmsRUsoyG83frY4');
    expect(json['google_place_name'], 'Le Jardin de l\'État');
    expect(json['time'], '');
  });
}
