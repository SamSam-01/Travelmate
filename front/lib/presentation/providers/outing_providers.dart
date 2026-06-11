import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/services/planned_outing_service.dart';
import 'package:front/services/user_service.dart' as front_user_service;
import 'package:front/services/activity_service.dart' as front_activity_service;
import 'package:front/models/activity_model.dart';

final plannedOutingServiceProvider = Provider<PlannedOutingService>((ref) {
  return const PlannedOutingService();
});

final sharedOutingsProvider = FutureProvider.family<List<PlannedOuting>, String>((ref, friendId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final currentUserId = supabase.auth.currentUser?.id;
  
  if (currentUserId == null || currentUserId.isEmpty) {
    return const <PlannedOuting>[];
  }

  final service = ref.watch(plannedOutingServiceProvider);
  final allOutings = await service.fetchPlannedOutings(currentUserId: currentUserId);

  return allOutings.where((outing) => outing.includesUserId(friendId)).toList(growable: false);
});

class OutingsData {
  const OutingsData({
    this.outings = const [],
    this.users = const [],
    this.activities = const [],
  });

  final List<PlannedOuting> outings;
  final List<PlannedOutingUser> users;
  final List<Activity> activities;
}

final outingsDataProvider = FutureProvider<OutingsData>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final currentUserId = supabase.auth.currentUser?.id;

  if (currentUserId == null || currentUserId.isEmpty) {
    return const OutingsData();
  }

  final plannedOutingService = ref.watch(plannedOutingServiceProvider);
  // In a real app we might inject these via providers too, but for simplicity:
  const userService = front_user_service.UserService();
  const activityService = front_activity_service.ActivityService();

  final results = await Future.wait([
    plannedOutingService.fetchPlannedOutings(currentUserId: currentUserId),
    userService.fetchUsers(),
    activityService.fetchActivities(),
  ]);

  return OutingsData(
    outings: results[0] as List<PlannedOuting>,
    users: results[1] as List<PlannedOutingUser>,
    activities: results[2] as List<Activity>,
  );
});
