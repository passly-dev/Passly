import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:syshack2026/common/widgets/passly_header.dart';
import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';

/// マイページの「友だち追加 (QR)」ボタンから開く QR 表示画面
/// (Figma node 1528:4287)。
///
/// 中央に自分の QR コードとユーザー名 (@名前) を表示する白カード + 下に
/// 「プロフィールをシェア」の 3 アクションカード。背景は緑→黄のブラー
/// グラデーション (Figma のイラスト SVG をそのまま利用)。
///
/// QR の中身は既存のマイページ内 QR と同じ `passly://profile/:userId` 形式。
/// スキャナ (mage:qr-code アイコン) は別 PR で実装予定。
class MyPageQrScreen extends ConsumerWidget {
  const MyPageQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authNotifierProvider).value;
    final userId = me?.id ?? '';
    final userName = me?.name ?? '';

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Stack(
        children: [
          // Figma node 1529:4399: 上 (緑 #6BD168) / 下 (黄 #F6C453) の 2 円を
          // stdDeviation=100 でブラーしたグラデーション。
          //
          // 元 SVG は assets/images/backgrounds/qr_gradient.svg に保存済みだが、
          // flutter_svg が feGaussianBlur フィルターを描画できないため、
          // ここでは 2 円 + ImageFiltered.blur で同じ見た目を再現する。
          const Positioned.fill(child: _QrGradientBackground()),
          SafeArea(
            child: Column(
              children: [
                PasslyHeader.qr(
                  onClose: () {
                    if (context.canPop()) context.pop();
                  },
                  onOpenScan: () => context.push('/mypage/qr/scan'),
                ),
                Expanded(
                  // Figma のレイアウトでは QR カード上端 = 238 (画面上端から)、
                  // 下端 = 646、画面高 892 → ヘッダー (110) 直下の残り 782 の
                  // 中で content 上 128 : 下 246 の比率。Align の y は
                  // (128 - 246) / (128 + 246) ≈ -0.32 で表現できる。
                  child: Align(
                    alignment: const Alignment(0, -0.32),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      // QR カードと下 3 枚のアクションカード行の横幅を揃えるため、
                      // Figma スペック (325px) を上限にした固定幅の Column に包む。
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 325),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _QrCard(userId: userId, userName: userName),
                            const SizedBox(height: PasslySpace.s8),
                            _ActionRow(userId: userId, userName: userName),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma node 1529:4395: 白背景の QR カード。
///
/// Figma スペックは正方形 (aspect 1:1) だが、`AspectRatio` で高さを幅に固定
/// すると狭幅端末で QR (230px) + 12px + username (24px) がオーバーフローする
/// ため、コンテンツ駆動のサイズにする。QR は最大 230 で親幅にフィット。
class _QrCard extends StatelessWidget {
  final String userId;
  final String userName;

  const _QrCard({required this.userId, required this.userName});

  String get _data => 'passly://profile/$userId';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 33),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth.clamp(0, 230).toDouble();
              return SizedBox(
                width: size,
                height: size,
                child: userId.isEmpty
                    ? const _QrPlaceholder()
                    : QrImageView(
                        data: _data,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.textPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.textPrimary,
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: PasslySpace.s12),
          Text(
            userName.isEmpty ? '' : '@$userName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: PasslyFont.family,
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: PasslyFont.medium,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Figma node 1529:4399: 端末サイズいっぱいに広がる緑/黄の 2 円グラデーション。
///
/// 元 SVG は 412x917 の viewBox に対して cx=(206, 9)/(206, 875) r=206 の
/// 緑 (#6BD168) と黄 (#F6C453) の 2 円を stdDeviation=100 でブラーしたもの。
/// flutter_svg は feGaussianBlur を描画できないため、Flutter 側で
/// [ImageFiltered] + [ImageFilter.blur] で同等の見た目を再現する。
class _QrGradientBackground extends StatelessWidget {
  const _QrGradientBackground();

  static const double _designWidth = 412;
  static const double _radius = 206;
  static const double _topCircleCy = 9;
  static const double _bottomCircleCy = 875;
  static const Color _greenColor = Color(0xFF6BD168);
  static const Color _yellowColor = Color(0xFFF6C453);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Figma のデザインサイズ (412x917) と実端末の縦横で伸び方が変わらない
        // よう幅ベースでスケール。端末が縦長すぎる場合でも 2 円の位置は
        // デザインどおりの相対座標を保つ。
        final scale = constraints.maxWidth / _designWidth;
        final scaledRadius = _radius * scale;
        final topCy = _topCircleCy * scale;
        final bottomCy = _bottomCircleCy * scale;
        final centerX = constraints.maxWidth / 2;

        return ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Stack(
              children: [
                Positioned(
                  left: centerX - scaledRadius,
                  top: topCy - scaledRadius,
                  child: _Circle(
                    diameter: scaledRadius * 2,
                    color: _greenColor,
                  ),
                ),
                Positioned(
                  left: centerX - scaledRadius,
                  top: bottomCy - scaledRadius,
                  child: _Circle(
                    diameter: scaledRadius * 2,
                    color: _yellowColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Circle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _Circle({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PasslyBg.elevated,
      alignment: Alignment.center,
      child: const Text(
        'ユーザー情報\n読み込み中',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: PasslyFont.family,
          color: PasslyText.secondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Figma node 1529:4433: 100x75 の白カード x 3 を justify-between で並べたアクション行。
///
/// Figma では 3 枚とも同じ文言 "プロフィールをシェア" だが、実機では動作が
/// 分かりにくかったため実装ではラベルを動作に沿って差し替える:
/// - share (humbleicons:share): 「プロフィールをシェア」→ システム共有シート
/// - link (bitcoin-icons:link-outline): 「リンクをコピー」→ URL をクリップボードへ
/// - download (fluent:arrow-download-32-light): 「ダウンロード」→ QR 画像保存 (未実装)
class _ActionRow extends StatelessWidget {
  final String userId;
  final String userName;

  const _ActionRow({required this.userId, required this.userName});

  String get _shareText => 'passly://profile/$userId';

  Future<void> _share(BuildContext context) async {
    if (userId.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(text: _shareText, subject: userName),
    );
  }

  Future<void> _copyLink(BuildContext context) async {
    if (userId.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィール URL をコピーしました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _download(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('画像保存は次のアップデートで実装予定です'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionCard(
          asset: PasslyIcons.share,
          label: 'プロフィールをシェア',
          onTap: () => _share(context),
        ),
        _ActionCard(
          asset: PasslyIcons.link,
          label: 'リンクをコピー',
          onTap: () => _copyLink(context),
        ),
        _ActionCard(
          asset: PasslyIcons.download,
          label: 'ダウンロード',
          onTap: () => _download(context),
        ),
      ],
    );
  }
}

/// Figma node 1529:4400 相当: 100x75 白カード + 25px アイコン + 9px ラベル。
class _ActionCard extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 100,
        height: 75,
        decoration: BoxDecoration(
          color: PasslyBg.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PasslyIcon(asset: asset, size: 22, color: AppColors.textPrimary),
            const SizedBox(height: 4),
            // Figma は 9px だがラベル文字数を変えた結果 "プロフィールをシェア"
            // (10 文字) が入らないので 10.5px + 最大 2 行で折り返す。
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
              softWrap: true,
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                color: AppColors.textPrimary,
                fontSize: 10.5,
                fontWeight: PasslyFont.regular,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
