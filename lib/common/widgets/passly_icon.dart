import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Passly のアイコンアセットパス定数。
///
/// Figma からエクスポートした SVG を `assets/images/icons/*.svg` に保存し、
/// [PasslyIcon] と組み合わせて色替え・サイズ調整して使う。
abstract final class PasslyIcons {
  static const String location = 'assets/images/icons/location.svg';
  static const String tag = 'assets/images/icons/tag.svg';
  static const String search = 'assets/images/icons/search.svg';
  static const String edit = 'assets/images/icons/edit.svg';

  /// 左向きシェブロン (< 形状)。右向きが必要な場合は
  /// [PasslyIcon.flipHorizontal] を true にする。
  static const String chevron = 'assets/images/icons/chevron.svg';

  /// akar-icons:fire。プロフィールのすれ違いピルなどで primary-light 着色で使用。
  static const String fire = 'assets/images/icons/fire.svg';

  /// ep:setting。マイページヘッダー右の歯車ボタンで使用。
  static const String settings = 'assets/images/icons/settings.svg';

  /// fluent-mdl2:add-friend。マイページヘッダーの QR / 友だち追加ボタンで使用。
  static const String addFriend = 'assets/images/icons/add_friend.svg';

  /// 30x30 X 型クローズアイコン (白 fill)。QR 画面ヘッダーの閉じるボタンで使用。
  static const String close = 'assets/images/icons/close.svg';

  /// mage:qr-code。QR 画面ヘッダーの QR スキャン起動ボタンで使用。
  static const String qrCode = 'assets/images/icons/qr_code.svg';

  /// humbleicons:share。QR 画面のシェアアクションで使用。
  static const String share = 'assets/images/icons/share.svg';

  /// bitcoin-icons:link-outline。QR 画面のリンクコピーアクションで使用。
  static const String link = 'assets/images/icons/link.svg';

  /// fluent:arrow-download-32-light。QR 画面の画像保存アクションで使用。
  static const String download = 'assets/images/icons/download.svg';
}

/// Passly の SVG アイコン描画ラッパ。
///
/// - [color] を渡すと `ColorFilter.mode(color, BlendMode.srcIn)` で単色に着色する
///   (元の fill / stroke どちらも上書きする)。null なら SVG 内の元色を維持。
/// - [flipHorizontal]=true で水平反転する。左向き chevron を右向きとして使う
///   ときなどに利用する。
class PasslyIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;
  final bool flipHorizontal;

  const PasslyIcon({
    super.key,
    required this.asset,
    required this.size,
    this.color,
    this.flipHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
    if (!flipHorizontal) return picture;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(-1, 1, 1),
      child: picture,
    );
  }
}
