import 'package:passly/features/encounter/domain/encounter_model.dart';
import 'package:passly/features/user/domain/common_tags.dart';

/// すれ違いの通知に出すタイトルと本文。
///
/// 11/8 のテストで「通知に気づかなかった」「確認するタイミングがなかった」
/// という声があったので，開かなくても誰と何が共通かが分かるようにする。
/// - タイトル: 未確認の人数
/// - 本文: いちばん新しくすれ違った人の名前と，自分との共通タグ（3 つまで）
({String title, String body}) encounterNotificationText({
  required List<EncounterModel> pending,
  required String myTechStack,
}) {
  if (pending.isEmpty) {
    return (title: 'すれ違いました！', body: 'アプリを開いて，すれ違った人を見てみましょう．');
  }

  final latest = pending.reduce(
    (a, b) => b.encounteredAt.isAfter(a.encounteredAt) ? b : a,
  );
  final rawName = latest.encounteredUser.name.trim();
  final name = rawName.isEmpty || rawName == '???' ? 'だれか' : '$rawNameさん';
  final title = pending.length == 1
      ? '$nameとすれ違いました！'
      : '${pending.length}人とすれ違いました！';

  final common = commonTechTags(myTechStack, latest.encounteredUser.techStack);
  final String body;
  if (common.isNotEmpty) {
    final shown = common.take(3).join('・');
    final more = common.length > 3 ? ' ほか${common.length - 3}個' : '';
    body = pending.length == 1
        ? '共通のタグ: $shown$more'
        : '$nameと共通のタグ: $shown$more';
  } else {
    body = pending.length == 1
        ? 'アプリを開いて，プロフィールを見てみましょう．'
        : '$nameなど．アプリを開いて，すれ違った人を見てみましょう．';
  }
  return (title: title, body: body);
}
