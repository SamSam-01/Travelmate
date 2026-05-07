import 'package:flutter/material.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/widgets/home_carousel.dart';

class PlannedOutingUser {
  const PlannedOutingUser({required this.id, required this.name});

  final String id;
  final String name;

  factory PlannedOutingUser.fromJson(dynamic json) {
    if (json is String) {
      return PlannedOutingUser(id: json, name: json);
    }

    if (json is Map<String, dynamic>) {
      return PlannedOutingUser(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? json['username'] ?? json['full_name'] ?? '')
            .toString(),
      );
    }

    return PlannedOutingUser(id: '', name: json?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class PlannedOutingActivity {
  const PlannedOutingActivity({
    required this.title,
    required this.time,
    this.activityId = '',
    this.subtitle = '',
    this.badge = '',
    this.tone = HomeCarouselTone.planned,
    this.icon = Icons.event_available_outlined,
  });

  PlannedOutingActivity.fromActivity(Activity activity, {required String time})
    : this(
        activityId: activity.id,
        title: activity.title,
        time: time,
        subtitle: activity.subtitle,
        badge: activity.badge,
        tone: activity.tone,
        icon: activity.icon,
      );

  final String activityId;

  final String title;
  final String time;
  final String subtitle;
  final String badge;
  final HomeCarouselTone tone;
  final IconData icon;

  factory PlannedOutingActivity.fromJson(dynamic json) {
    if (json is String) {
      return PlannedOutingActivity(title: json, time: '');
    }

    if (json is Map<String, dynamic>) {
      final nestedActivity = json['activity'];
      if (nestedActivity is Map<String, dynamic>) {
        final activity = Activity.fromJson(nestedActivity);
        return PlannedOutingActivity.fromActivity(
          activity,
          time: (json['time'] ?? json['hour'] ?? json['starts_at'] ?? '')
              .toString(),
        );
      }

      return PlannedOutingActivity(
        activityId: (json['activity_id'] ?? json['id'] ?? '').toString(),
        title: (json['title'] ?? json['name'] ?? json['label'] ?? '')
            .toString(),
        time: (json['time'] ?? json['hour'] ?? json['starts_at'] ?? '')
            .toString(),
        subtitle: (json['subtitle'] ?? '').toString(),
        badge: (json['badge'] ?? '').toString(),
        tone: _toneFromValue(json['tone']),
        icon: _iconFromValue(json['icon_key'] ?? json['icon']),
      );
    }

    return PlannedOutingActivity(title: json?.toString() ?? '', time: '');
  }

  Map<String, dynamic> toJson() => {'activity_id': activityId, 'time': time};

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
      _ => HomeCarouselTone.planned,
    };
  }

  static IconData _iconFromValue(dynamic value) {
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
      _ => Icons.event_available_outlined,
    };
  }
}

class PlannedOuting {
  const PlannedOuting({
    required this.id,
    required this.title,
    required this.users,
    required this.activities,
    this.createdAt,
  });

  final String id;
  final String title;
  final List<PlannedOutingUser> users;
  final List<PlannedOutingActivity> activities;
  final DateTime? createdAt;

  factory PlannedOuting.fromJson(Map<String, dynamic> json) {
    return PlannedOuting(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      users: _parseUsers(json['users'] ?? json['participants']),
      activities: _parseActivities(json['activities'] ?? json['itinerary']),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  static List<PlannedOutingUser> _parseUsers(dynamic value) {
    if (value is List) {
      return value
          .map(PlannedOutingUser.fromJson)
          .where((user) => user.id.isNotEmpty || user.name.isNotEmpty)
          .toList(growable: false);
    }

    return const <PlannedOutingUser>[];
  }

  static List<PlannedOutingActivity> _parseActivities(dynamic value) {
    if (value is List) {
      return value
          .map(PlannedOutingActivity.fromJson)
          .where((activity) => activity.title.isNotEmpty)
          .toList(growable: false);
    }

    return const <PlannedOutingActivity>[];
  }

  bool includesUserId(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return false;
    }

    return users.any((user) => user.id == normalizedUserId);
  }

  Map<String, dynamic> toInsertJson() => {'title': title};

  HomeCarouselItem toCarouselItem() {
    final participantsLabel = users.isEmpty
        ? 'Aucun participant'
        : users.map((user) => user.name).take(3).join(', ');
    final activityLabel = activities.isEmpty
        ? 'Aucune activité planifiée'
        : activities
              .take(2)
              .map(
                (activity) =>
                    '${activity.time.isEmpty ? 'Heure libre' : activity.time} ${activity.title}',
              )
              .join(' • ');

    return HomeCarouselItem(
      title: title,
      subtitle: '$participantsLabel • $activityLabel',
      badge: users.isEmpty ? 'Planifiée' : '${users.length} pers.',
      icon: Icons.event_available_outlined,
      tone: HomeCarouselTone.planned,
    );
  }

  String get summaryText {
    final participants = users.isEmpty
        ? 'Aucun participant'
        : '${users.length} participant${users.length > 1 ? 's' : ''}';
    final activityCount = activities.isEmpty
        ? 'Aucune activité'
        : '${activities.length} activité${activities.length > 1 ? 's' : ''}';
    return '$participants • $activityCount';
  }
}
