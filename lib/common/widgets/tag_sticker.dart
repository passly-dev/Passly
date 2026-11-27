import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passly/core/constants/passly_tokens.dart';

/// タグのロゴと色。ロゴがないタグは [asset] が null で，文字のステッカーにする。
class TagLogo {
  final String? asset;
  final Color color;

  /// ロゴがないときに出す短い文字（例: AWS → "AWS"，C# → "C#"）。
  final String text;

  const TagLogo({this.asset, required this.color, required this.text});

  static const _fallbackColor = Color(0xFF6B7280);

  static const Map<String, TagLogo> _byTag = {
    'dart': TagLogo(asset: 'dart', color: Color(0xFF0175C2), text: 'Dart'),
    'go': TagLogo(asset: 'go', color: Color(0xFF00ADD8), text: 'Go'),
    'python': TagLogo(asset: 'python', color: Color(0xFF3776AB), text: 'Py'),
    'javascript': TagLogo(
      asset: 'javascript',
      color: Color(0xFFF7DF1E),
      text: 'JS',
    ),
    'typescript': TagLogo(
      asset: 'typescript',
      color: Color(0xFF3178C6),
      text: 'TS',
    ),
    'java': TagLogo(asset: 'java', color: Color(0xFFE76F00), text: 'Java'),
    'ruby': TagLogo(asset: 'ruby', color: Color(0xFFCC342D), text: 'Ruby'),
    'php': TagLogo(asset: 'php', color: Color(0xFF777BB4), text: 'PHP'),
    'rust': TagLogo(asset: 'rust', color: Color(0xFF000000), text: 'Rust'),
    'c': TagLogo(asset: 'c', color: Color(0xFFA8B9CC), text: 'C'),
    'c++': TagLogo(asset: 'cplusplus', color: Color(0xFF00599C), text: 'C++'),
    'c#': TagLogo(asset: 'csharp', color: Color(0xFF68217A), text: 'C#'),
    'scala': TagLogo(asset: 'scala', color: Color(0xFFDC322F), text: 'Scala'),
    'elixir': TagLogo(asset: 'elixir', color: Color(0xFF8847B9), text: 'Ex'),
    'haskell': TagLogo(asset: 'haskell', color: Color(0xFF5D4F85), text: 'Hs'),
    'react': TagLogo(asset: 'react', color: Color(0xFF61DAFB), text: 'React'),
    'vue': TagLogo(asset: 'vuedotjs', color: Color(0xFF4FC08D), text: 'Vue'),
    'angular': TagLogo(asset: 'angular', color: Color(0xFFDD0031), text: 'Ng'),
    'next.js': TagLogo(
      asset: 'nextdotjs',
      color: Color(0xFF000000),
      text: 'Next',
    ),
    'nuxt': TagLogo(asset: 'nuxt', color: Color(0xFF00DC82), text: 'Nuxt'),
    'svelte': TagLogo(asset: 'svelte', color: Color(0xFFFF3E00), text: 'Sv'),
    'astro': TagLogo(asset: 'astro', color: Color(0xFFBC52EE), text: 'Astro'),
    'vite': TagLogo(asset: 'vite', color: Color(0xFF9135FF), text: 'Vite'),
    'tailwind': TagLogo(
      asset: 'tailwindcss',
      color: Color(0xFF06B6D4),
      text: 'TW',
    ),
    'sass': TagLogo(asset: 'sass', color: Color(0xFFCC6699), text: 'Sass'),
    'shadcn/ui': TagLogo(
      asset: 'shadcnui',
      color: Color(0xFF000000),
      text: 'ui',
    ),
    'jquery': TagLogo(asset: 'jquery', color: Color(0xFF0769AD), text: 'jQ'),
    'three.js': TagLogo(
      asset: 'threedotjs',
      color: Color(0xFF000000),
      text: '3js',
    ),
    'storybook': TagLogo(
      asset: 'storybook',
      color: Color(0xFFFF4785),
      text: 'SB',
    ),
    'flutter': TagLogo(
      asset: 'flutter',
      color: Color(0xFF02569B),
      text: 'Flutter',
    ),
    'react native': TagLogo(
      asset: 'react',
      color: Color(0xFF61DAFB),
      text: 'RN',
    ),
    'swift': TagLogo(asset: 'swift', color: Color(0xFFF05138), text: 'Swift'),
    'kotlin': TagLogo(asset: 'kotlin', color: Color(0xFF7F52FF), text: 'Kt'),
    'swiftui': TagLogo(asset: 'swift', color: Color(0xFF0D96F6), text: 'SUI'),
    'jetpack compose': TagLogo(
      asset: 'jetpackcompose',
      color: Color(0xFF4285F4),
      text: 'JC',
    ),
    'expo': TagLogo(asset: 'expo', color: Color(0xFF1C2024), text: 'Expo'),
    'node.js': TagLogo(
      asset: 'nodedotjs',
      color: Color(0xFF5FA04E),
      text: 'Node',
    ),
    'express': TagLogo(asset: 'express', color: Color(0xFF0A0A0A), text: 'Ex'),
    'nestjs': TagLogo(asset: 'nestjs', color: Color(0xFFE0234E), text: 'Nest'),
    'hono': TagLogo(asset: 'hono', color: Color(0xFFE36002), text: 'Hono'),
    'django': TagLogo(asset: 'django', color: Color(0xFF092E20), text: 'Dj'),
    'fastapi': TagLogo(asset: 'fastapi', color: Color(0xFF009688), text: 'API'),
    'flask': TagLogo(asset: 'flask', color: Color(0xFF3BABC3), text: 'Flask'),
    'rails': TagLogo(
      asset: 'rubyonrails',
      color: Color(0xFFD30001),
      text: 'Rails',
    ),
    'spring': TagLogo(asset: 'spring', color: Color(0xFF6DB33F), text: 'Sp'),
    'laravel': TagLogo(asset: 'laravel', color: Color(0xFFFF2D20), text: 'Lv'),
    'gin': TagLogo(asset: 'gin', color: Color(0xFF008ECF), text: 'Gin'),
    'fastify': TagLogo(asset: 'fastify', color: Color(0xFF000000), text: 'Fy'),
    'graphql': TagLogo(asset: 'graphql', color: Color(0xFFE10098), text: 'GQL'),
    'deno': TagLogo(asset: 'deno', color: Color(0xFF000000), text: 'Deno'),
    'bun': TagLogo(asset: 'bun', color: Color(0xFFFBF0DF), text: 'Bun'),
    'aws': TagLogo(asset: 'aws', color: Color(0xFFFF9900), text: 'AWS'),
    'gcp': TagLogo(asset: 'googlecloud', color: Color(0xFF4285F4), text: 'GCP'),
    'azure': TagLogo(asset: 'azure', color: Color(0xFF0078D4), text: 'Azure'),
    'firebase': TagLogo(
      asset: 'firebase',
      color: Color(0xFFDD2C00),
      text: 'Fb',
    ),
    'supabase': TagLogo(
      asset: 'supabase',
      color: Color(0xFF3FCF8E),
      text: 'Sb',
    ),
    'vercel': TagLogo(asset: 'vercel', color: Color(0xFF000000), text: 'Vc'),
    'cloudflare': TagLogo(
      asset: 'cloudflare',
      color: Color(0xFFF38020),
      text: 'CF',
    ),
    'netlify': TagLogo(asset: 'netlify', color: Color(0xFF00C7B7), text: 'Nf'),
    'render': TagLogo(asset: 'render', color: Color(0xFF000000), text: 'Rn'),
    'docker': TagLogo(asset: 'docker', color: Color(0xFF2496ED), text: 'Dk'),
    'kubernetes': TagLogo(
      asset: 'kubernetes',
      color: Color(0xFF326CE5),
      text: 'k8s',
    ),
    'terraform': TagLogo(
      asset: 'terraform',
      color: Color(0xFF844FBA),
      text: 'Tf',
    ),
    'nginx': TagLogo(asset: 'nginx', color: Color(0xFF009639), text: 'Nx'),
    'github actions': TagLogo(
      asset: 'githubactions',
      color: Color(0xFF2088FF),
      text: 'GHA',
    ),
    'postgresql': TagLogo(
      asset: 'postgresql',
      color: Color(0xFF4169E1),
      text: 'PG',
    ),
    'mysql': TagLogo(asset: 'mysql', color: Color(0xFF4479A1), text: 'My'),
    'mariadb': TagLogo(asset: 'mariadb', color: Color(0xFF003545), text: 'Ma'),
    'mongodb': TagLogo(asset: 'mongodb', color: Color(0xFF47A248), text: 'Mg'),
    'redis': TagLogo(asset: 'redis', color: Color(0xFFFF4438), text: 'Rd'),
    'sqlite': TagLogo(asset: 'sqlite', color: Color(0xFF003B57), text: 'SQL'),
    'prisma': TagLogo(asset: 'prisma', color: Color(0xFF2D3748), text: 'Pr'),
    'pytorch': TagLogo(asset: 'pytorch', color: Color(0xFFEE4C2C), text: 'PT'),
    'tensorflow': TagLogo(
      asset: 'tensorflow',
      color: Color(0xFFFF6F00),
      text: 'TF',
    ),
    'pandas': TagLogo(asset: 'pandas', color: Color(0xFF150458), text: 'pd'),
    'jupyter': TagLogo(asset: 'jupyter', color: Color(0xFFF37626), text: 'Jup'),
    'langchain': TagLogo(
      asset: 'langchain',
      color: Color(0xFF1C3C3C),
      text: 'LC',
    ),
    'unity': TagLogo(asset: 'unity', color: Color(0xFF000000), text: 'Unity'),
    'unreal engine': TagLogo(
      asset: 'unrealengine',
      color: Color(0xFF0E1128),
      text: 'UE',
    ),
    'godot': TagLogo(
      asset: 'godotengine',
      color: Color(0xFF478CBF),
      text: 'Godot',
    ),
    'blender': TagLogo(asset: 'blender', color: Color(0xFFE87D0D), text: 'Bl'),
    'arduino': TagLogo(asset: 'arduino', color: Color(0xFF00878F), text: 'Ard'),
    'raspberry pi': TagLogo(
      asset: 'raspberrypi',
      color: Color(0xFFA22846),
      text: 'RPi',
    ),
    'ros': TagLogo(asset: 'ros', color: Color(0xFF22314E), text: 'ROS'),
    'figma': TagLogo(asset: 'figma', color: Color(0xFFF24E1E), text: 'Figma'),
    'adobe xd': TagLogo(asset: 'xd', color: Color(0xFFFF61F6), text: 'Xd'),
    'photoshop': TagLogo(
      asset: 'photoshop',
      color: Color(0xFF31A8FF),
      text: 'Ps',
    ),
    'illustrator': TagLogo(
      asset: 'illustrator',
      color: Color(0xFFFF9A00),
      text: 'Ai',
    ),
    'canva': TagLogo(asset: 'canva', color: Color(0xFF00C4CC), text: 'Canva'),
    'git': TagLogo(asset: 'git', color: Color(0xFFF03C2E), text: 'Git'),
    'github': TagLogo(asset: 'github', color: Color(0xFF181717), text: 'GH'),
    'gitlab': TagLogo(asset: 'gitlab', color: Color(0xFFFC6D26), text: 'GL'),
    'linux': TagLogo(asset: 'linux', color: Color(0xFFFCC624), text: 'Linux'),
    'vscode': TagLogo(asset: 'vscode', color: Color(0xFF007ACC), text: 'VS'),
    'vim': TagLogo(asset: 'vim', color: Color(0xFF019733), text: 'Vim'),
    'notion': TagLogo(asset: 'notion', color: Color(0xFF000000), text: 'N'),
    'discord': TagLogo(asset: 'discord', color: Color(0xFF5865F2), text: 'Dc'),
  };

  /// タグ名（大文字小文字は無視）からロゴを引く。カタログにないタグは灰色の文字。
  static TagLogo of(String tag) {
    final hit = _byTag[tag.trim().toLowerCase()];
    if (hit != null) return hit;
    final t = tag.trim();
    return TagLogo(
      color: _fallbackColor,
      text: t.length <= 4 ? t : t.substring(0, 3),
    );
  }

  String? get assetPath => asset == null ? null : 'assets/tags/$asset.svg';
}

/// タグごとに決まった少しの傾き（ラジアン）。
///
/// 開くたびに角度が変わらないよう，タグ名から決める。-2.5°〜2.5°。
double tagStickerAngle(String tag) {
  const degrees = [-2.5, -1.5, -1.0, 1.0, 1.5, 2.5, -2.0, 2.0];
  var h = 0;
  for (final c in tag.toLowerCase().codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return degrees[h % degrees.length] * math.pi / 180;
}

/// タグのステッカー。
///
/// ロゴは元の色のまま，まわりを白いふちで囲んだシール。
/// [same] が true（自分と同じタグ）のときは，ふちを緑にして右上にチェックを付ける。
/// [onRemove] を渡すと右上に灰色の×が出て，押すと外せる（プロフィール編集用）。
class TagSticker extends StatelessWidget {
  final String tag;
  final double size;
  final bool same;
  final bool dimmed;
  final bool tilt;
  final VoidCallback? onRemove;

  const TagSticker({
    super.key,
    required this.tag,
    this.size = 48,
    this.same = false,
    this.dimmed = false,
    this.tilt = true,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final logo = TagLogo.of(tag);
    final border = size >= 40 ? 4.0 : 2.5;
    final radius = size * 0.3;
    final logoSize = size * 0.56;
    final asset = logo.assetPath;

    Widget face = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          logo.color.withValues(alpha: 0.1),
          Colors.white,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: same ? PasslyBrand.primary : Colors.white,
          width: border,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: size >= 40 ? 6 : 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: asset != null
          ? SvgPicture.asset(asset, width: logoSize, height: logoSize)
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(size * 0.08),
                child: Text(
                  logo.text,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: logo.color,
                    fontSize: size * 0.32,
                    fontWeight: PasslyFont.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
    );
    if (dimmed) face = Opacity(opacity: 0.55, child: face);

    final badgeSize = math.max(14.0, size * 0.38);
    final badge = same
        ? _Badge(
            size: badgeSize,
            color: PasslyBrand.primary,
            icon: Icons.check_rounded,
          )
        : onRemove != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: _Badge(
              size: badgeSize,
              color: const Color(0xFF6B7280),
              icon: Icons.close_rounded,
            ),
          )
        : null;

    final sticker = Semantics(
      label: same ? '$tag（あなたと同じタグ）' : tag,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            face,
            if (badge != null)
              Positioned(
                right: -badgeSize * 0.4,
                top: -badgeSize * 0.4,
                child: badge,
              ),
          ],
        ),
      ),
    );
    if (!tilt) return sticker;
    return Transform.rotate(angle: tagStickerAngle(tag), child: sticker);
  }
}

class _Badge extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _Badge({required this.size, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size >= 18 ? 2 : 1.5),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: size * 0.62),
    );
  }
}

/// ステッカーの下にタグ名を付けたもの。マイページ・相手のプロフィール・編集画面・すれ違い画面で使う。
class LabeledTagSticker extends StatelessWidget {
  final String tag;
  final double size;
  final bool same;
  final bool dimmed;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  /// 1 つ分の横幅。省略するとタグ名が収まる幅（[defaultWidth]）にする。
  final double? width;

  const LabeledTagSticker({
    super.key,
    required this.tag,
    this.size = 48,
    this.width,
    this.same = false,
    this.dimmed = false,
    this.onRemove,
    this.onTap,
  });

  /// [size] のステッカーを並べるときの 1 つ分の横幅
  static double defaultWidth(double size) => math.max(size + 16, 68);

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: width ?? defaultWidth(size),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TagSticker(
            tag: tag,
            size: size,
            same: same,
            dimmed: dimmed,
            onRemove: onRemove,
          ),
          const SizedBox(height: 7),
          Text(
            tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: same ? PasslyBrand.primaryDark : PasslyText.secondary,
              fontSize: 10,
              fontWeight: PasslyFont.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}

/// 一覧の行で使う小さいステッカーの並び。[maxVisible] を超えた分は「+N」。
///
/// [common] に入っているタグ（大文字小文字は無視）は緑のふち＋チェック。
class TagStickerRow extends StatelessWidget {
  final List<String> tags;
  final List<String> common;
  final int maxVisible;
  final double size;

  const TagStickerRow({
    super.key,
    required this.tags,
    this.common = const [],
    this.maxVisible = 4,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final commonLower = common.map((t) => t.toLowerCase()).toSet();
    // 同じタグを先に並べる。
    final ordered = [
      ...tags.where((t) => commonLower.contains(t.toLowerCase())),
      ...tags.where((t) => !commonLower.contains(t.toLowerCase())),
    ];
    final visible = ordered.take(maxVisible).toList();
    final rest = ordered.length - visible.length;
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in visible) ...[
            TagSticker(
              tag: t,
              size: size,
              same: commonLower.contains(t.toLowerCase()),
            ),
            const SizedBox(width: 7),
          ],
          if (rest > 0)
            Text(
              '+$rest',
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                color: PasslyText.secondary,
                fontSize: 11,
                fontWeight: PasslyFont.medium,
              ),
            ),
        ],
      ),
    );
  }
}
