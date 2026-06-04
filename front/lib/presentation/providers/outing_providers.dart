import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/presentation/providers/friendship_providers.dart';
import 'package:front/services/planned_outing_service.dart';

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
