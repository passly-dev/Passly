import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/encounter/domain/encounter_model.dart';
import 'package:passly/features/notification/encounter_notification_text.dart';

EncounterModel _person(String name, String tags, int minute) => EncounterModel(
  id: name,
  encounteredUser: EncounteredUserInfo(id: name, name: name, techStack: tags),
  encounteredAt: DateTime(2026, 11, 28, 14, minute),
);

void main() {
  test('1人なら名前と共通タグを出す', () {
    final t = encounterNotificationText(
      pending: [_person('あおい', 'Flutter,Go,Figma', 0)],
      myTechStack: 'Figma,Flutter',
    );
    expect(t.title, 'あおいさんとすれ違いました！');
    expect(t.body, '共通のタグ: Flutter・Figma');
  });

  test('複数人なら人数と，いちばん新しい人の共通タグを出す', () {
    final t = encounterNotificationText(
      pending: [
        _person('あおい', 'Go', 5),
        _person('いずみ', 'Flutter,Go,Figma,React,Swift', 10),
        _person('うみ', 'Rust', 1),
      ],
      myTechStack: 'Figma,Flutter,Go,React,Swift',
    );
    expect(t.title, '3人とすれ違いました！');
    expect(t.body, 'いずみさんと共通のタグ: Flutter・Go・Figma ほか2個');
  });

  test('共通タグがなければプロフィールを見るように案内する', () {
    final t = encounterNotificationText(
      pending: [_person('あおい', 'Rust', 0)],
      myTechStack: 'Figma',
    );
    expect(t.body, 'アプリを開いて，プロフィールを見てみましょう．');
  });

  test('一覧がまだ取れていなくても通知を出せる', () {
    final t = encounterNotificationText(pending: const [], myTechStack: '');
    expect(t.title, 'すれ違いました！');
  });
}
