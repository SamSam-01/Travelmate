import 'package:flutter/material.dart';
import 'package:front/widgets/home_carousel.dart';

class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.tone,
    required this.icon,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final HomeCarouselTone tone;
  final IconData icon;
  final int sortOrder;

  factory Activity.fromJson(Map<String, dynamic> json) {
    final tone = _toneFromValue(json['tone'] ?? json['category']);
    final icon = _iconFromValue(
      json['icon_key'] ?? json['icon'] ?? json['iconName'],
      tone,
    );

    return Activity(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      badge: (json['badge'] ?? '').toString(),
      tone: tone,
      icon: icon,
      sortOrder: _intFromValue(json['sort_order'] ?? json['order_index']),
    );
  }

  HomeCarouselItem toCarouselItem() {
    return HomeCarouselItem(
      title: title,
      subtitle: subtitle,
      badge: badge,
      icon: icon,
      tone: tone,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'badge': badge,
      'tone': tone.name,
      'icon_key': _keyFromIcon(icon) ?? 'location_city_outlined',
      'sort_order': sortOrder,
    };
  }

  static int _intFromValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static HomeCarouselTone _toneFromValue(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();

    return switch (normalized) {
      'nature' => HomeCarouselTone.nature,
      'city' => HomeCarouselTone.city,
      'food' => HomeCarouselTone.food,
      'culture' => HomeCarouselTone.culture,
      'planned' => HomeCarouselTone.planned,
      'hiking' => HomeCarouselTone.hiking,
      'dinner' => HomeCarouselTone.dinner,
      'water' => HomeCarouselTone.water,
      _ => HomeCarouselTone.city,
    };
  }

  static IconData _iconFromValue(dynamic value, HomeCarouselTone tone) {
    final normalized = value?.toString().trim().toLowerCase();

    return switch (normalized) {
      'terrain_outlined' => Icons.terrain_outlined,
      'location_city_outlined' => Icons.location_city_outlined,
      'restaurant_outlined' => Icons.restaurant_outlined,
      'museum_outlined' => Icons.museum_outlined,
      'hiking_outlined' => Icons.hiking_outlined,
      'event_available_outlined' => Icons.event_available_outlined,
      'dinner_dining_outlined' => Icons.dinner_dining_outlined,
      'water_outlined' => Icons.water_outlined,
      _ => switch (tone) {
        HomeCarouselTone.nature => Icons.terrain_outlined,
        HomeCarouselTone.city => Icons.location_city_outlined,
        HomeCarouselTone.food => Icons.restaurant_outlined,
        HomeCarouselTone.culture => Icons.museum_outlined,
        HomeCarouselTone.planned => Icons.event_available_outlined,
        HomeCarouselTone.hiking => Icons.hiking_outlined,
        HomeCarouselTone.dinner => Icons.dinner_dining_outlined,
        HomeCarouselTone.water => Icons.water_outlined,
      },
    };
  }

  static String? _keyFromIcon(IconData icon) {
    if (icon == Icons.terrain_outlined) return 'terrain_outlined';
    if (icon == Icons.location_city_outlined) return 'location_city_outlined';
    if (icon == Icons.restaurant_outlined) return 'restaurant_outlined';
    if (icon == Icons.museum_outlined) return 'museum_outlined';
    if (icon == Icons.hiking_outlined) return 'hiking_outlined';
    if (icon == Icons.event_available_outlined) return 'event_available_outlined';
    if (icon == Icons.dinner_dining_outlined) return 'dinner_dining_outlined';
    if (icon == Icons.water_outlined) return 'water_outlined';
    return null;
  }
}
