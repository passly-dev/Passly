import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:passly/common/widgets/tag_sticker.dart';
import 'package:passly/features/user/data/tech_tag_catalog.dart';

void main() {
  test('カタログのタグはすべてロゴか文字のステッカーになる', () {
    for (final tag in TechTagCatalog.allTags) {
      final logo = TagLogo.of(tag);
      expect(logo.text, isNotEmpty, reason: tag);
    }
  });

  test('大文字小文字が違っても同じロゴになる', () {
    expect(TagLogo.of('flutter').assetPath, TagLogo.of('Flutter').assetPath);
    expect(TagLogo.of('Flutter').assetPath, 'assets/tags/flutter.svg');
  });

  test('カタログのタグはすべてロゴの画像がある', () {
    for (final tag in TechTagCatalog.allTags) {
      final path = TagLogo.of(tag).assetPath;
      expect(path, isNotNull, reason: tag);
      expect(File(path!).existsSync(), isTrue, reason: path);
    }
  });

  test('カタログにないタグは文字のステッカーになる', () {
    expect(TagLogo.of('Unknown').assetPath, isNull);
    expect(TagLogo.of('Unknown').text, 'Unk');
  });

  test('傾きはタグごとに決まっていて ±2.5° に収まる', () {
    for (final tag in TechTagCatalog.allTags) {
      final a = tagStickerAngle(tag);
      expect(a, tagStickerAngle(tag));
      expect(a.abs(), lessThanOrEqualTo(2.5 * 3.1416 / 180));
    }
  });
}
