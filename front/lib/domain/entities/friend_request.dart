import 'package:front/domain/entities/user_profile.dart';

enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.requester,
    required this.addressee,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final UserProfile requester;
  final UserProfile addressee;
  final FriendRequestStatus status;
  final DateTime createdAt;
}
