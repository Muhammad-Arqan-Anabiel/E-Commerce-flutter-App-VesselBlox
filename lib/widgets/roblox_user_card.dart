import 'package:flutter/material.dart';
import '../models/roblox_user_model.dart';
import '../theme/app_theme.dart';

class RobloxUserCard extends StatelessWidget {
  final RobloxUser user;
  final bool confirmed;
  final bool isId;
  final VoidCallback onConfirm;
  final VoidCallback onChange;

  const RobloxUserCard({
    Key? key,
    required this.user,
    required this.confirmed,
    required this.isId,
    required this.onConfirm,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardWash,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: confirmed ? AppTheme.emeraldGreen.withOpacity(0.4) : AppTheme.hairline,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: AppTheme.hairline),
            ),
            child: ClipOval(
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                    )
                  : const Icon(Icons.person, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.displayName,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Colors.lightBlueAccent),
                    ],
                    if (confirmed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.3)),
                        ),
                        child: Text(
                          isId ? '✓ Dikonfirmasi' : '✓ Confirmed',
                          style: const TextStyle(
                            color: AppTheme.emeraldGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.username} • ID: ${user.id}',
                  style: const TextStyle(
                    color: AppTheme.textAshDim,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          if (!confirmed)
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purplePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                isId ? 'Ini Akunku' : 'This is Me',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: onChange,
              child: Text(
                isId ? 'Ganti' : 'Change',
                style: const TextStyle(fontSize: 11, color: AppTheme.textAsh, decoration: TextDecoration.underline),
              ),
            ),
        ],
      ),
    );
  }
}
