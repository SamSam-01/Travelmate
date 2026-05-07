class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.isPrivate,
  });

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final bool isPrivate;
}
