class RobloxUser {
  final int id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool verified;

  RobloxUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.verified = false,
  });

  factory RobloxUser.fromJson(Map<String, dynamic> json, {String? avatarUrl}) {
    return RobloxUser(
      id: json['id'] as int? ?? 0,
      username: json['name'] as String? ?? (json['username'] as String? ?? ''),
      displayName: json['displayName'] as String? ?? (json['name'] as String? ?? ''),
      avatarUrl: avatarUrl,
      verified: json['hasVerifiedBadge'] as bool? ?? (json['verified'] as bool? ?? false),
    );
  }
}
