import 'package:flutter/material.dart';

/// ユーザーのRoleに応じたアバターアイコンを表示する共通Widget
class RoleAvatarWidget extends StatelessWidget {
  final String roleIcon;
  final double size;

  const RoleAvatarWidget({super.key, required this.roleIcon, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
      child: Text(roleIcon, style: TextStyle(fontSize: size * 0.5)),
    );
  }

  /// UserRoleの文字列から絵文字アイコンを取得するヘルパー
  static String iconForRole(String role) {
    switch (role) {
      case 'frontend':
        return '🎨';
      case 'backend':
        return '⚙️';
      case 'fullstack':
        return '🚀';
      default:
        return '💻';
    }
  }
}
