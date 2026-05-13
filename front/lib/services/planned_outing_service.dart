import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/utils/planned_outing_relations.dart';

class PlannedOutingService {
  const PlannedOutingService();

  Future<List<PlannedOuting>> fetchPlannedOutings({
    required String currentUserId,
  }) async {
    final outingRows = await supabase
        .from('planned_outings')
        .select('id, title, scheduled_for, created_at')
        .order('created_at', ascending: false);

    if (outingRows.isEmpty) {
      return const <PlannedOuting>[];
    }

    final participantRows = await supabase
        .from('planned_outing_participants')
        .select('planned_outing_id, profile_id');

    final profileRows = await supabase.from('profiles').select('id, username');

    final activityLinkRows = await supabase
        .from('planned_outing_activities')
        .select('planned_outing_id, activity_id, time, sort_order')
        .order('sort_order');

    final activityRows = await supabase
        .from('activities')
        .select('id, title, subtitle, badge, tone, icon_key, sort_order');

    final usersByOutingId = _buildUsersByOutingId(
      participantRows: participantRows,
      profileRows: profileRows,
    );
    final activitiesByOutingId = _buildActivitiesByOutingId(
      activityLinkRows: activityLinkRows,
      activityRows: activityRows,
    );

    return buildPlannedOutingsFromRelations(
      outingRows: outingRows
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false),
      usersByOutingId: usersByOutingId,
      activitiesByOutingId: activitiesByOutingId,
      currentUserId: currentUserId,
    );
  }

  Future<PlannedOuting> createPlannedOuting({
    required String title,
    required List<PlannedOutingUser> users,
    required List<PlannedOutingActivity> activities,
    DateTime? scheduledFor,
  }) async {
    final createdOuting = await supabase
        .from('planned_outings')
        .insert({
          'title': title,
          'scheduled_for': scheduledFor?.toIso8601String(),
        })
        .select('id, title, scheduled_for, created_at')
        .single();

    final outingId = (createdOuting['id'] ?? '').toString();

    await _insertParticipants(outingId: outingId, users: users);
    await _insertActivities(outingId: outingId, activities: activities);

    return PlannedOuting(
      id: outingId,
      title: (createdOuting['title'] ?? title).toString(),
      users: users,
      activities: activities,
      scheduledFor: DateTime.tryParse(
        (createdOuting['scheduled_for'] ?? '').toString(),
      ),
      createdAt: DateTime.tryParse(
        (createdOuting['created_at'] ?? '').toString(),
      ),
    );
  }

  Map<String, List<PlannedOutingUser>> _buildUsersByOutingId({
    required List<dynamic> participantRows,
    required List<dynamic> profileRows,
  }) {
    final profileById = <String, String>{
      for (final profileRow in profileRows)
        (profileRow['id'] ?? '').toString():
            (profileRow['username'] ?? profileRow['id'] ?? '').toString(),
    };

    final grouped = <String, List<PlannedOutingUser>>{};
    for (final row in participantRows) {
      final outingId = (row['planned_outing_id'] ?? '').toString();
      final profileId = (row['profile_id'] ?? '').toString();
      if (outingId.isEmpty || profileId.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(outingId, () => <PlannedOutingUser>[]);
      grouped[outingId]!.add(
        PlannedOutingUser(
          id: profileId,
          name: profileById[profileId] ?? profileId,
        ),
      );
    }

    return grouped;
  }

  Map<String, List<PlannedOutingActivity>> _buildActivitiesByOutingId({
    required List<dynamic> activityLinkRows,
    required List<dynamic> activityRows,
  }) {
    final activityById = <String, Activity>{
      for (final activityRow in activityRows)
        (activityRow['id'] ?? '').toString(): Activity.fromJson(
          Map<String, dynamic>.from(activityRow as Map),
        ),
    };

    final grouped = <String, List<_ActivityLink>>{};
    for (final row in activityLinkRows) {
      final outingId = (row['planned_outing_id'] ?? '').toString();
      final activityId = (row['activity_id'] ?? '').toString();
      final time = (row['time'] ?? '').toString();
      final sortOrder = _intFromValue(row['sort_order']);

      if (outingId.isEmpty || activityId.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(outingId, () => <_ActivityLink>[]);
      grouped[outingId]!.add(
        _ActivityLink(activityId: activityId, time: time, sortOrder: sortOrder),
      );
    }

    return {
      for (final entry in grouped.entries)
        entry.key: (entry.value
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder))),
    }.map(
      (outingId, links) => MapEntry(
        outingId,
        links
            .map((link) {
              final activity = activityById[link.activityId];
              if (activity == null) {
                return PlannedOutingActivity(
                  activityId: link.activityId,
                  title: link.activityId,
                  time: link.time,
                );
              }

              return PlannedOutingActivity.fromActivity(
                activity,
                time: link.time,
              );
            })
            .toList(growable: false),
      ),
    );
  }

  Future<void> _insertParticipants({
    required String outingId,
    required List<PlannedOutingUser> users,
  }) async {
    if (outingId.isEmpty || users.isEmpty) {
      return;
    }

    await supabase
        .from('planned_outing_participants')
        .insert(
          users
              .where((user) => user.id.isNotEmpty)
              .map(
                (user) => {
                  'planned_outing_id': outingId,
                  'profile_id': user.id,
                },
              )
              .toList(growable: false),
        );
  }

  Future<void> _insertActivities({
    required String outingId,
    required List<PlannedOutingActivity> activities,
  }) async {
    if (outingId.isEmpty || activities.isEmpty) {
      return;
    }

    await supabase
        .from('planned_outing_activities')
        .insert(
          activities
              .asMap()
              .entries
              .where((entry) => entry.value.activityId.isNotEmpty)
              .map(
                (entry) => {
                  'planned_outing_id': outingId,
                  'activity_id': entry.value.activityId,
                  'time': entry.value.time,
                  'sort_order': entry.key,
                },
              )
              .toList(growable: false),
        );
  }

  static int _intFromValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ActivityLink {
  const _ActivityLink({
    required this.activityId,
    required this.time,
    required this.sortOrder,
  });

  final String activityId;
  final String time;
  final int sortOrder;
}
