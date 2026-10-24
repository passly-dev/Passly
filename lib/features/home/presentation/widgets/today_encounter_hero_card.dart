import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1079:865 「今日のすれ違いカード」。
///
/// 破線の緑ボーダーは Figma エクスポートの SVG (手描き風の波形ダッシュ) を、
/// 内側の公園イラストは PNG を、それぞれレイヤーして再現する。
///
/// - `today_encounter_border.svg` : 波形の破線ボーダーのみ (透明背景)
/// - `today_encounter_bg.png` : 公園のイラスト
///
/// flutter_svg が SVG 内の `<image>` (base64) を描画できないため、SVG からは
/// 白の内側塗りと埋め込み画像を取り除き、PNG を別レイヤーとして重ねる方式に
/// した。ドロップシャドウは Container 側で担当する。
///
/// アバターは NetworkImage (icon_url) を想定。空リストの場合はアバターを描画しない。
class TodayEncounterHeroCard extends StatelessWidget {
  final int todayCount;
  final List<String> avatarUrls;

  const TodayEncounterHeroCard({
    super.key,
    required this.todayCount,
    this.avatarUrls = const [],
  });

  // 見た目上のカード領域 (Figma 原寸)。
  static const double _designW = 382;
  static const double _designH = 208.364;
  static const double _borderRadius = 23.152;

  // 境界 SVG の viewBox は 0 0 459 286 で、ドロップシャドウ用のパディングを含む。
  // 見た目のカード始点はその中の (38.0767, 35.9934)。
  static const String _borderAsset =
      'assets/images/home/today_encounter_border.svg';
  static const String _bgAsset = 'assets/images/home/today_encounter_bg.png';
  static const double _svgW = 459;
  static const double _svgH = 286;
  static const double _svgCardLeft = 38.0767;
  static const double _svgCardTop = 35.9934;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designW;
          return _buildCard(scale);
        },
      ),
    );
  }

  Widget _buildCard(double scale) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 白ベース + 影 + 角丸 + PNG 公園イラストをまとめて敷く。
        Container(
          width: _designW * scale,
          height: _designH * scale,
          decoration: BoxDecoration(
            color: PasslyBg.surface,
            borderRadius: BorderRadius.circular(_borderRadius * scale),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 2.315),
                blurRadius: 34.727,
                color: Color(0x407E857E),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage(_bgAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 手描き風の波形ダッシュボーダー (SVG)。透明背景で境界だけを重ねる。
        Positioned(
          left: -_svgCardLeft * scale,
          top: -_svgCardTop * scale,
          width: _svgW * scale,
          height: _svgH * scale,
          child: SvgPicture.asset(_borderAsset, fit: BoxFit.fill),
        ),
        // タイトル + カウント (左上)。Figma spec は w=129.648 だが Chrome の
        // Noto Sans JP Black メトリクスがわずかに広く「今日のすれ違い」が改行する
        // ため、右のアバター開始位置 (left=220) まで許容して no-wrap で表示する。
        Positioned(
          left: 21.15 * scale,
          top: 16.52 * scale,
          width: (220 - 21.15) * scale,
          child: _TitleAndCount(scale: scale, count: todayCount),
        ),
        // アバター 3 個 (右下)
        ..._buildAvatars(scale),
      ],
    );
  }

  List<Widget> _buildAvatars(double scale) {
    // Figma spec: 全て top=137, left=220/257/295, size=57.88
    const size = 57.88;
    const top = 137.0;
    const lefts = [220.0, 257.0, 295.0];
    // 表示するアバター数は「今日出会った人数」を最大 3 でクランプ。URL が
    // 与えられていない枠はプレースホルダアイコンで表示する。
    final slots = todayCount.clamp(0, 3);
    final avatars = <Widget>[];
    for (int i = 0; i < slots; i++) {
      final url = i < avatarUrls.length ? avatarUrls[i] : '';
      avatars.add(
        Positioned(
          left: lefts[i] * scale,
          top: top * scale,
          width: size * scale,
          height: size * scale,
          child: _AvatarCircle(url: url),
        ),
      );
    }
    return avatars;
  }
}

class _TitleAndCount extends StatelessWidget {
  final double scale;
  final int count;

  const _TitleAndCount({required this.scale, required this.count});

  @override
  Widget build(BuildContext context) {
    // Figma: Noto Sans JP Black (w900)、PasslyFont は w700 までしか定義が無いため w900 を直接指定。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日のすれ違い',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontFamily: PasslyFont.family,
            fontWeight: FontWeight.w900,
            fontSize: 18.521 * scale,
            height: 22.225 / 18.521,
            color: PasslyText.primary,
          ),
        ),
        SizedBox(height: 15.048 * scale),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: PasslyFont.family,
              fontWeight: FontWeight.w900,
              color: PasslyText.primary,
              height: 22.225 / 55.564,
            ),
            children: [
              TextSpan(
                text: '$count',
                style: TextStyle(fontSize: 55.564 * scale),
              ),
              TextSpan(
                text: '人',
                style: TextStyle(fontSize: 18.521 * scale),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String url;

  const _AvatarCircle({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _AvatarFallback();
    return ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarFallback(),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PasslyBg.elevated,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: PasslyText.tertiary),
    );
  }
}
