import 'package:front/main.dart';
import 'package:front/models/planned_outing_model.dart';

class PlannedOutingService {
  const PlannedOutingService();

  Future<List<PlannedOuting>> fetchPlannedOutings() async {
    final rows = await supabase
        .from('planned_outings')
        .select('id, title, users, activities, created_at')
        .order('created_at', ascending: false);

    return rows
        .map<PlannedOuting>((row) => PlannedOuting.fromJson(row))
        .where((outing) => outing.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<PlannedOuting> createPlannedOuting({
    required String title,
    required List<PlannedOutingUser> users,
    required List<PlannedOutingActivity> activities,
  }) async {
    final response = await supabase
        .from('planned_outings')
        .insert({
          'title': title,
          'users': users.map((user) => user.toJson()).toList(growable: false),
          'activities': activities
              .map((activity) => activity.toJson())
              .toList(growable: false),
        })
        .select('id, title, users, activities, created_at')
        .single();

    return PlannedOuting.fromJson(response);
  }
}
