import 'package:front/data/models/friend_request_model.dart';
import 'package:front/data/models/profile_model.dart';
import 'package:front/domain/entities/friend_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendshipRemoteDataSource {
  const FriendshipRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<ProfileModel>> searchUsersByUsername(String query) async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('profile_search')
        .select('id, username, display_name')
        .ilike('username', '%${query.trim()}%')
        .neq('id', currentUserId)
        .order('username')
        .limit(20);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(ProfileModel.fromSearchJson).toList(growable: false);
  }

  Future<FriendRequestModel> sendFriendRequest(String addresseeId) async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('friendships')
        .insert(<String, dynamic>{
          'requester_id': currentUserId,
          'addressee_id': addresseeId,
          'status': FriendRequestStatus.pending.name,
        })
        .select('id, requester_id, addressee_id, status, created_at')
        .single();

    return _buildFriendRequestFromRow(
      Map<String, dynamic>.from(response),
      usePublicProfiles: true,
    );
  }

  Future<FriendRequestModel> respondToRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    final response = await _client
        .from('friendships')
        .update(<String, dynamic>{'status': status.name})
        .eq('id', requestId)
        .select('id, requester_id, addressee_id, status, created_at')
        .single();

    return _buildFriendRequestFromRow(
      Map<String, dynamic>.from(response),
      usePublicProfiles: true,
    );
  }

  Future<List<FriendRequestModel>> getPendingRequests() async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('friendships')
        .select('id, requester_id, addressee_id, status, created_at')
        .eq('addressee_id', currentUserId)
        .eq('status', FriendRequestStatus.pending.name)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response);
    return _buildFriendRequestsFromRows(rows, usePublicProfiles: true);
  }

  Future<List<ProfileModel>> getFriends() async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('friendships')
        .select('requester_id, addressee_id')
        .eq('status', FriendRequestStatus.accepted.name)
        .or('requester_id.eq.$currentUserId,addressee_id.eq.$currentUserId');

    final rows = List<Map<String, dynamic>>.from(response);
    final friendIds = rows
        .map((row) {
          final requesterId = row['requester_id'] as String;
          final addresseeId = row['addressee_id'] as String;
          return requesterId == currentUserId ? addresseeId : requesterId;
        })
        .toSet()
        .toList(growable: false);

    final profiles = await _fetchFullProfilesByIds(friendIds);
    return friendIds
        .map((id) => profiles[id])
        .whereType<ProfileModel>()
        .toList(growable: false);
  }

  Future<Set<String>> getOutgoingPendingRequestIds() async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('friendships')
        .select('addressee_id')
        .eq('requester_id', currentUserId)
        .eq('status', FriendRequestStatus.pending.name);

    return List<Map<String, dynamic>>.from(
      response,
    ).map((row) => row['addressee_id'] as String).toSet();
  }

  Future<ProfileModel> getCurrentUserProfile() async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('profiles')
        .select('id, username, display_name, avatar_url, is_private')
        .eq('id', currentUserId)
        .single();

    return ProfileModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<ProfileModel> updateCurrentUserProfile(ProfileModel profile) async {
    final currentUserId = _requireCurrentUserId();
    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', currentUserId)
        .select('id, username, display_name, avatar_url, is_private')
        .single();

    return ProfileModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<FriendRequestModel>> _buildFriendRequestsFromRows(
    List<Map<String, dynamic>> rows, {
    required bool usePublicProfiles,
  }) async {
    if (rows.isEmpty) {
      return const <FriendRequestModel>[];
    }

    final ids = rows
        .expand(
          (row) => <String>[
            row['requester_id'] as String,
            row['addressee_id'] as String,
          ],
        )
        .toSet()
        .toList(growable: false);
    final profiles = usePublicProfiles
        ? await _fetchPublicProfilesByIds(ids)
        : await _fetchFullProfilesByIds(ids);

    return rows
        .map(
          (row) => FriendRequestModel.fromRow(
            row: row,
            requester: profiles[row['requester_id']]!,
            addressee: profiles[row['addressee_id']]!,
          ),
        )
        .toList(growable: false);
  }

  Future<FriendRequestModel> _buildFriendRequestFromRow(
    Map<String, dynamic> row, {
    required bool usePublicProfiles,
  }) async {
    final requests = await _buildFriendRequestsFromRows(<Map<String, dynamic>>[
      row,
    ], usePublicProfiles: usePublicProfiles);
    return requests.first;
  }

  Future<Map<String, ProfileModel>> _fetchPublicProfilesByIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return <String, ProfileModel>{};
    }

    final response = await _client
        .from('profile_search')
        .select('id, username, display_name')
        .inFilter('id', userIds);

    return {
      for (final row in List<Map<String, dynamic>>.from(response))
        (row['id'] as String): ProfileModel.fromSearchJson(row),
    };
  }

  Future<Map<String, ProfileModel>> _fetchFullProfilesByIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return <String, ProfileModel>{};
    }

    final response = await _client
        .from('profiles')
        .select('id, username, display_name, avatar_url, is_private')
        .inFilter('id', userIds);

    return {
      for (final row in List<Map<String, dynamic>>.from(response))
        (row['id'] as String): ProfileModel.fromJson(row),
    };
  }

  String _requireCurrentUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('No authenticated user found.');
    }
    return userId;
  }
}
