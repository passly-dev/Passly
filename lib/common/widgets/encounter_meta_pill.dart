import 'package:flutter/material.dart';

import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/core/utils/app_time.dart';

/// Figma node 1240:1405 「すれ違い日時ピル」。
///
/// プロフィール画面などで「いつ / どこで出会ったか」を 1 行で表示する
/// 382x52 の白いピル。左に炎アイコン (primary-light)、右にテキスト。
///
/// テキスト表記: `{M月D日} {location} で出会いました`。
/// 完全に自由な文言を渡したい場合は [text] に文字列を渡す。
class EncounterMetaPill extends StatelessWidget {
  /// 出会った日時。null の場合は [text] が必須。
  final DateTime? date;

  /// 出会った場所 / イベント名。null の場合は [text] が必須。
  final String? location;

  /// 完全に自由なテキスト。指定した場合は [date] / [location] は無視される。
  final String? text;

  const EncounterMetaPill({super.key, this.date, this.location, this.text})
    : assert(
        text != null || (date != null && location != null),
        'text または (date と location) のいずれかを指定してください',
      );

  static const double _height = 52;
  static const double _radius = 100;
  static const double _horizontalPadding = 54;
  static const double _verticalPadding = 15;
  static const double _iconSize = 20;
  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: PasslyBorder.strong, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D707C70),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PasslyIcon(asset: PasslyIcons.fire, size: _iconSize),
          const SizedBox(width: _gap),
          Flexible(
            child: Text(
              text ?? _formatDefault(date!, location!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                color: Colors.black,
                fontSize: 14,
                fontWeight: PasslyFont.medium,
                height: 16.8 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDefault(DateTime dateUtc, String location) {
    final date = AppTime.toAppLocal(dateUtc);
    return '${date.month}月${date.day}日 $location で出会いました';
  }
}
