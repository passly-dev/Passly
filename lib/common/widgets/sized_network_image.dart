import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// ネットワーク画像の読み込み元。アプリでは端末に保存して，2 回目からはすぐ出す。
/// テストでは端末の保存先が使えないので，ふつうの読み込みにする。
ImageProvider passlyNetworkImage(String url) =>
    _useDiskCache ? CachedNetworkImageProvider(url) : NetworkImage(url);

final bool _useDiskCache = () {
  try {
    return !Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return true;
  }
}();

/// 表示する大きさに合わせて縮めてから読み込むネットワーク画像。
///
/// 画像は端末に保存し（[passlyNetworkImage]），アプリを開き直しても
/// ダウンロードし直さない。
///
/// アイコンやイベント画像は元の画像（512px 以上）をそのまま読むと，
/// 40px ほどの丸に出すだけでもメモリとデコードの時間を使う。
/// 置かれた枠の大きさ × 画面の倍率を目安に縮めて読み込み，一覧のスクロールを軽くする。
/// 縦横比が枠と違っても [BoxFit.cover] で粗くならないよう，長い辺に少し余裕を持たせる。
class SizedNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final bool gaplessPlayback;
  final Widget Function(BuildContext context) fallback;

  const SizedNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.gaplessPlayback = false,
  });

  /// 枠の大きさから，読み込むときの一辺の長さ（px）を出す。枠が決まらなければ null。
  static int? decodeSize(BoxConstraints c, double devicePixelRatio) {
    final w = c.maxWidth.isFinite ? c.maxWidth : null;
    final h = c.maxHeight.isFinite ? c.maxHeight : null;
    final side = [
      w,
      h,
    ].whereType<double>().fold<double>(0, (a, b) => a > b ? a : b);
    if (side <= 0) return null;
    return (side * devicePixelRatio * 1.5).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = decodeSize(constraints, dpr);
        final ImageProvider provider = size == null
            ? passlyNetworkImage(url)
            : ResizeImage(
                passlyNetworkImage(url),
                width: size,
                height: size,
                policy: ResizeImagePolicy.fit,
                allowUpscaling: false,
              );
        return Image(
          image: provider,
          fit: fit,
          width: width,
          gaplessPlayback: gaplessPlayback,
          errorBuilder: (context, _, _) => fallback(context),
        );
      },
    );
  }
}
