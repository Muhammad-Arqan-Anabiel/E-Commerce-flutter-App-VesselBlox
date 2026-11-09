import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/roblox_user_model.dart';

class RobloxService {
  static final RegExp _usernameRegex =
      RegExp(r'^(?!_)(?!.*_.*_)[A-Za-z0-9_]{3,20}(?<!_)$');

  static final Map<String, RobloxUser?> _cache = {};

  static bool isValidUsername(String name) {
    return _usernameRegex.hasMatch(name.trim());
  }

  static Future<RobloxUser?> lookupUser(String rawName) async {
    final name = rawName.trim();
    if (!isValidUsername(name)) return null;

    final key = name.toLowerCase();
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final userResponse = await http.post(
        Uri.parse('https://users.roblox.com/v1/usernames/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usernames': [name],
          'excludeBannedUsers': true,
        }),
      ).timeout(const Duration(seconds: 8));

      if (userResponse.statusCode != 200) {
        return null;
      }

      final userData = jsonDecode(userResponse.body) as Map<String, dynamic>;
      final userList = userData['data'] as List<dynamic>?;
      if (userList == null || userList.isEmpty) {
        _cache[key] = null;
        return null;
      }

      final firstUser = userList[0] as Map<String, dynamic>;
      final userId = firstUser['id'] as int;

      String? avatarUrl;
      try {
        final thumbResponse = await http.get(
          Uri.parse(
            'https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=$userId&size=150x150&format=Png&isCircular=false',
          ),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (thumbResponse.statusCode == 200) {
          final thumbData = jsonDecode(thumbResponse.body) as Map<String, dynamic>;
          final thumbList = thumbData['data'] as List<dynamic>?;
          if (thumbList != null && thumbList.isNotEmpty) {
            final t = thumbList[0] as Map<String, dynamic>;
            if (t['state'] == 'Completed') {
              avatarUrl = t['imageUrl'] as String?;
            }
          }
        }
      } catch (_) {
        // Avatar is optional
      }

      final robloxUser = RobloxUser.fromJson(firstUser, avatarUrl: avatarUrl);
      _cache[key] = robloxUser;
      return robloxUser;
    } catch (_) {
      return null;
    }
  }
}
