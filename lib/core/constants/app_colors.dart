import 'package:flutter/material.dart';

/// アプリ全体で使用するカラー定数。
///
/// デザイントークンとして一元管理し、各画面での直接的な
/// Color(0xFF...) 指定を避けるために使用する。
abstract final class AppColors {
  // ─── ブランドカラー ───────────────────────────────────

  /// メインのブランドグリーン。ボタン・アクセント・アイコンなど広範囲で使用
  static const Color primary = Color(0xFF3AAA3A);

  // ─── テキスト ─────────────────────────────────────────

  /// 見出し・本文の主要テキスト色
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// 補足テキスト・ラベル・ヒント
  static const Color textSecondary = Color(0xFF757575);

  /// プレースホルダー・無効状態のテキスト
  static const Color textDisabled = Color(0xFF9E9E9E);

  /// 軽い無効状態（プロフィール未設定時など）
  static const Color textLight = Color(0xFFBDBDBD);

  // ─── 背景 ─────────────────────────────────────────────

  /// 標準の白背景
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  /// 入力フィールド・セクション背景などの薄いグレー
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  /// ダークモード系の画面背景（スプラッシュ、すれ違い結果）
  static const Color backgroundDark = Color(0xFF0D0D0D);

  /// ダークモード系のカード背景
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ─── ボーダー・ディバイダー ────────────────────────────

  /// 区切り線・ボーダーの標準色
  static const Color divider = Color(0xFFE0E0E0);

  // ─── エラー・警告 ─────────────────────────────────────

  /// エラーテキスト・アイコン
  static const Color error = Color(0xFFE53935);

  /// エラー強調（濃い赤）
  static const Color errorDark = Color(0xFFB71C1C);

  /// エラーバナーの背景
  static const Color errorBackground = Color(0xFFFDE8E8);

  // ─── SNS・外部サービスのブランドカラー ────────────────

  /// 技術スタック・リンクアイコンなどの青
  static const Color iconBlue = Color(0xFF1565C0);

  /// 所属・組織アイコンのオレンジ
  static const Color iconOrange = Color(0xFFFF6F00);

  /// Twitter / X のブランドカラー
  static const Color iconTwitter = Color(0xFF1DA1F2);

  /// GitHub のブランドカラー
  static const Color iconGitHub = Color(0xFF333333);

  // ─── その他 ───────────────────────────────────────────

  /// スタンプカードのアイコン（アンバー）
  static const Color stampGold = Color(0xFFF59E0B);

  /// カレンダーの日曜日テキスト色（error と同値だが用途が異なる）
  static const Color calendarSunday = Color(0xFFE53935);

  /// カレンダーの土曜日テキスト色
  static const Color calendarSaturday = Color(0xFF1565C0);
}
