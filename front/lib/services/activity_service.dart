import 'package:front/main.dart';
import 'package:front/models/activity_model.dart';

class ActivityService {
  const ActivityService();

  Future<List<Activity>> fetchActivities() async {
    final rows = await supabase
        .from('activities')
        .select('id, title, subtitle, badge, tone, icon_key, sort_order')
        .order('sort_order');

    return rows
        .map<Activity>((row) => Activity.fromJson(row))
        .where((activity) => activity.title.isNotEmpty)
        .toList(growable: false);
  }
}
