import 'package:front/main.dart';
import 'package:front/models/planned_outing_model.dart';

class UserService {
  const UserService();

  Future<List<PlannedOutingUser>> fetchUsers() async {
    final rows = await supabase
        .from('profiles')
        .select('id, username')
        .order('username');

    return rows
        .map<PlannedOutingUser>((row) {
          return PlannedOutingUser.fromJson({
            'id': row['id'],
            'name': row['username'] ?? row['id'],
          });
        })
        .where((user) => user.id.isNotEmpty)
        .toList(growable: false);
  }
}
