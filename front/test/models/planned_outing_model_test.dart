import 'package:flutter_test/flutter_test.dart';
import 'package:front/models/planned_outing_model.dart';

void main() {
  group('PlannedOutingUser', () {
    test('should return pending status by default when parsing from json string', () {
      final user = PlannedOutingUser.fromJson('user_123');
      expect(user.id, 'user_123');
      expect(user.name, 'user_123');
      expect(user.status, 'pending');
    });

    test('should parse status correctly from map', () {
      final json = {'id': '123', 'name': 'Alice', 'status': 'accepted'};
      final user = PlannedOutingUser.fromJson(json);
      expect(user.id, '123');
      expect(user.name, 'Alice');
      expect(user.status, 'accepted');
    });

    test('should output status to json map', () {
      const user = PlannedOutingUser(id: '1', name: 'Bob', status: 'declined');
      final json = user.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Bob');
      expect(json['status'], 'declined');
    });
  });

  group('PlannedOuting', () {
    test('should correctly identify user status', () {
      const users = [
        PlannedOutingUser(id: 'u1', name: 'User 1', status: 'accepted'),
        PlannedOutingUser(id: 'u2', name: 'User 2', status: 'pending'),
      ];
      const outing = PlannedOuting(
        id: 'o1',
        title: 'Sortie',
        users: users,
        activities: [],
      );

      expect(outing.isUserAccepted('u1'), isTrue);
      expect(outing.isUserPending('u1'), isFalse);
      
      expect(outing.isUserAccepted('u2'), isFalse);
      expect(outing.isUserPending('u2'), isTrue);

      expect(outing.isUserAccepted('u3'), isFalse);
      expect(outing.isUserPending('u3'), isFalse);
    });
  });
}
