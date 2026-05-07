import 'package:front/data/models/profile_model.dart';
import 'package:front/domain/entities/friend_request.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required ProfileModel super.requester,
    required ProfileModel super.addressee,
    required super.status,
    required super.createdAt,
  });

  factory FriendRequestModel.fromRow({
    required Map<String, dynamic> row,
    required ProfileModel requester,
    required ProfileModel addressee,
  }) {
    return FriendRequestModel(
      id: row['id'] as String,
      requester: requester,
      addressee: addressee,
      status: _parseStatus(row['status'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'requester': (requester as ProfileModel).toJson(),
      'addressee': (addressee as ProfileModel).toJson(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static FriendRequestStatus _parseStatus(String? value) {
    return FriendRequestStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FriendRequestStatus.pending,
    );
  }
}
