# Passly コードリーディング順（Flutter 初学者向け）

このリポジトリを **一人で読めるようになる** ための、依存関係を意識したファイル読破ガイド。
lib/ 配下の全 60 ファイルを読む必要はない。**まずは 25 ファイル**、5 ファイルごとに理解を確認しながら進めれば、機能追加・バグ修正に踏み込めるレベルになる。

---

## 0. 事前に押さえておく概念（コード外・各 10 分）

コードに入る前にこの 4 つだけ雰囲気で分かればOK。分からなくても進みながら戻ってこられる。

| 概念 | ざっくり |
|---|---|
| **Riverpod (`Provider` / `Notifier` / `AsyncNotifier`)** | Flutter の状態管理。`ref.watch(xxxProvider)` で値購読、`ref.read(xxxProvider.notifier).method()` で書き換え。 |
| **`freezed`** | 不変データクラス + `copyWith` + `fromJson` を自動生成するコード生成ツール。`.freezed.dart` `.g.dart` は触らない。 |
| **`GoRouter`** | 宣言的ルーティング。`context.go('/home')` で画面遷移。 |
| **BLE (Bluetooth Low Energy)** | Scan（受信）と Advertise（発信）の 2 種類の動作がある。Passly は両方同時に走らせて「すれ違い」を実現している。 |

---

## Phase 1: アプリの骨組みを掴む（合計 45 分）

「アプリが起動してどの画面に飛ぶか」を追える状態にする。

### 1. `pubspec.yaml`（5 分）
- **目的**：どんな外部ライブラリを使っているかを一望する
- **絶対理解**：`flutter_riverpod` / `go_router` / `dio` / `flutter_blue_plus` / `flutter_ble_peripheral` / `freezed` の 6 つが主役だと知る

### 2. `lib/main.dart`（5 分）
- **目的**：エントリーポイントと `MaterialApp.router` の構造
- **絶対理解**：`ProviderScope` でアプリ全体をラップしないと Riverpod が動かない、ということ

### 3. `lib/core/constants/app_colors.dart`（5 分）
- **目的**：色は全部ここに定数化されている
- **絶対理解**：新しい色を追加したくなったら、必ずこのファイルに書き足してから使う

### 4. `lib/core/network/dio_client.dart`（10 分）
- **目的**：API 通信の入口 (`dioProvider`) と、端末内暗号化ストレージ (`secureStorageProvider`) の定義
- **絶対理解**：**すべての Repository はこの `dioProvider` を経由してバックエンドを叩く**。API URL もここで固定されている

### 5. `lib/common/router/app_router.dart`（20 分）
- **目的**：全ルート定義と、ログイン状態による redirect ロジック
- **絶対理解**：`redirect:` の 3 行 — 「ログイン済 × 認証ページ ⇒ `/home`、未ログイン × 認証以外 ⇒ `/login`」がアプリ全体の遷移を支配している

### ✅ チェックポイント 1
- [ ] アプリ起動時に `ProviderScope → PasslyApp → GoRouter` の順で組み上がる流れが言える
- [ ] ログインしていないユーザーが `/home` を開こうとしたら何が起きるか説明できる
- [ ] `StatefulShellRoute` が「タブを切り替えても各タブの状態が保持される仕組み」だと分かる

---

## Phase 2: 認証とユーザーモデル（合計 55 分）

「ログインしてサーバーからユーザーデータを取ってくる」流れを追う。ここで Riverpod + freezed + Dio の 3 点セットの使い方が身につく。

### 6. `lib/features/user/domain/user_role.dart`（3 分）
- **目的**：ユーザーのロール enum を眺める
- **絶対理解**：バックエンドとは文字列 `"frontend"` などで通信する

### 7. `lib/features/user/domain/user_model.dart`（15 分）
- **目的**：**アプリ内で最重要のデータクラス**。ユーザー情報の全フィールド
- **絶対理解**：`fromJson` 内で「バックエンドの `snake_case` → Dart の `camelCase`」に手動マッピングしている理由（null 対策）

### 8. `lib/features/user/data/user_repository.dart`（10 分）
- **目的**：`GET /users/:id` / `PATCH` / `DELETE` / アバターアップロードの生の HTTP 呼び出し
- **絶対理解**：**Repository は Dio を触るだけ**。UI・状態管理には触らない、という責務分離

### 9. `lib/features/auth/data/auth_repository.dart`（12 分）
- **目的**：ログイン・サインアップ・セッション復元
- **絶対理解**：ログイン成功時、レスポンスの `user_id` を **`FlutterSecureStorage` に保存 → 次回起動でこれを読んで自動ログイン**

### 10. `lib/features/auth/domain/auth_notifier.dart`（15 分）
- **目的**：認証状態のグローバル管理 `AsyncNotifierProvider<AuthNotifier, UserModel?>`
- **絶対理解**：`build()` が **アプリ起動時に自動で 1 度だけ走り**、保存済 user_id からセッションを復元する（＝スプラッシュ画面の裏で動いているのはこいつ）

### ✅ チェックポイント 2
- [ ] アプリ起動 → `AuthNotifier.build()` → セッション復元 → `UserModel` が state に入る、を絵で描ける
- [ ] 「ログイン画面のボタンを押すと `AuthNotifier.login()` が呼ばれて state が変わる」までの経路を追える
- [ ] `AsyncValue` の `data / loading / error` 3 状態の意味を説明できる

---

## Phase 3: 認証まわりの UI と、タブ画面の骨組み（合計 50 分）

Riverpod の `ref.watch` / `ref.listen` の使い分けと、アプリライフサイクルの管理を学ぶ。

### 11. `lib/features/auth/presentation/splash_screen.dart`（10 分）
- **目的**：起動直後の 2 秒間 + 認証状態のポーリング
- **絶対理解**：`_wakeUpServer()` は **Render 無料枠がスリープするから叩き起こしている**、という運用事情由来のコード

### 12. `lib/features/auth/presentation/login_screen.dart`（15 分）
- **目的**：`ref.listen` パターンの教科書例
- **絶対理解**：`ref.watch` は「値が変わったら再ビルド」、`ref.listen` は「変わったら副作用（画面遷移など）」— この使い分け

### 13. `lib/features/auth/presentation/sign_up_screen.dart`（10 分・軽く）
- **目的**：長い Form の書き方の見本。一度に全部読まなくてよい
- **絶対理解**：構造は `LoginScreen` とほぼ同じ、と分かればOK

### 14. `lib/main_screen.dart`（15 分）
- **目的**：**このプロジェクトで一番濃い 300 行**。4 タブ画面 + BLE ライフサイクル + アプリライフサイクル監視
- **絶対理解**：`WidgetsBindingObserver` で `resumed/paused/detached` を検知し、状態に応じて BLE の開始・停止を切り替えている。**BLE を一切知らなくても「ここで開始・停止している」ことだけは把握**

### 15. `lib/common/widgets/animated_bottom_nav_bar.dart`（5 分・見るだけ）
- **目的**：カスタムのアニメ付きボトムナビ
- **絶対理解**：中身はほぼ独立した UI 部品。触るのは色変更くらいで十分

### ✅ チェックポイント 3
- [ ] 「ログイン成功 → `authNotifierProvider` の state が更新 → `RouterNotifier` が発火 → `redirect` で `/home` へ」を追える
- [ ] タブ画面に来た直後になぜ BLE が開始されるのか（`_startBleIfLoggedIn`）を説明できる
- [ ] アプリをホーム画面に戻した時（`AppLifecycleState.resumed`）に何が起きるか分かる

---

## Phase 4: BLE すれ違いの中核（合計 90 分）

**このアプリの本丸**。ここを理解すれば「Passly の技術的な差別化ポイント」が全部分かる。時間かかってOK。

### 16. `lib/features/ble/ble_service.dart`（30 分）
- **目的**：`flutter_blue_plus` / `flutter_ble_peripheral` を叩く生の BLE 実装
- **絶対理解**：**Scan（受信）と Advertise（発信）は独立して同時に動く**。localName に `SP_{ephemeralId}` を埋め込み、5 分ごとにトークンを更新している

### 17. `lib/features/encounter/domain/encounter_model.dart`（8 分）
- **目的**：「すれ違い 1 件」のデータ構造
- **絶対理解**：`freezed` + `@JsonKey(name: 'event_id')` で snake_case ↔ camelCase を吸収するパターン

### 18. `lib/features/encounter/data/encounter_repository.dart`（15 分）
- **目的**：`/encounters` `/ephemeral-token` `/achievements` などの API
- **絶対理解**：**エフェメラルトークン**：BLE で流すのは実 user_id ではなく短命トークン。プライバシー保護のキモ

### 19. `lib/features/encounter/data/pending_encounter_repository.dart`（10 分）
- **目的**：未確認すれ違いを **端末内に JSON で保存** する
- **絶対理解**：`FlutterSecureStorage` は「小さな key-value 用の暗号化ストレージ」。JSON を突っ込んでも動く（ただし本格 DB ではない）

### 20. `lib/features/ble/ble_notifier.dart`（25 分）
- **目的**：**BLE と Encounter と Auth を統合する司令塔**。`ble_service` を裏方として使う
- **絶対理解**：`_handleEncounterConfirmed` — BLE で他端末を検知 → `recordEncounter` API 呼び出し → `encounterNotifierProvider.refresh()` で結果画面遷移をトリガー、というリレーの起点

### ✅ チェックポイント 4
- [ ] 「相手の端末が自分の localName を検知 → `BleService` の onEncounterConfirmed → `BleNotifier._handleEncounterConfirmed` → サーバー POST → EncounterNotifier 更新」の一連を追える
- [ ] エフェメラルトークンを 5 分ごとに更新する理由（プライバシー保護）を説明できる
- [ ] `docs/diagrams/01_ble_encounter_flow.png` を見て、コードとの対応がつく

---

## Phase 5: 結果画面と各タブの UI（合計 60 分）

ここまで来れば残りは組み合わせだけ。**Riverpod を「消費する側」のテンプレを 2 つの画面で見る**。

### 21. `lib/features/encounter/domain/encounter_notifier.dart`（20 分）
- **目的**：未確認すれ違いの一覧管理。サーバー・ローカル両方から取得
- **絶対理解**：`build()` はアプリ起動時に走り、`refresh()` は BLE 検知後や画面遷移前に手動で呼ばれる

### 22. `lib/features/encounter/presentation/encounter_result_screen.dart`（15 分・UI 部分は流し読みOK）
- **目的**：`PageView` を無限ループさせて Mii 広場風にアバターを並べる画面
- **絶対理解**：「確認してホームへ」ボタン → `confirmAll()` → サーバーに `PUT /encounters/confirm` → `context.go('/home')` の流れ

### 23. `lib/features/home/data/home_repository.dart` + `home/domain/home_notifier.dart`（10 分）
- **目的**：**最もシンプルな Repository + AsyncNotifier のペア**。他のタブを追加する時のテンプレになる
- **絶対理解**：`fetchHomeData()` は 1 回の API で 4 種のデータをまとめて取ってくる（`total_encounters` / `today_encounters` / `unconfirmed` / `random_three`）

### 24. `lib/features/home/presentation/home_screen.dart`（10 分）
- **目的**：`ref.watch(homeNotifierProvider)` + `state.when(data/loading/error)` の教科書パターン
- **絶対理解**：`RefreshIndicator` で下スワイプすると `refresh()` を呼ぶ、という UX を実装するパターン

### 25. `lib/features/encounter/domain/daily_limit_service.dart`（5 分）
- **目的**：「1 日 5 人まで」の制限を端末側で管理
- **絶対理解**：**サーバーではなく端末のセキュアストレージ**にカウントを持つ設計判断（不正防止より簡潔さ優先）

### ✅ チェックポイント 5
- [ ] 新しいタブを 1 つ追加するとしたら、どのファイルをどの順で作ればよいか手順化できる（Repository → Notifier → Screen）
- [ ] BLE 検知から結果画面表示までの全経路をコードで追える
- [ ] `homeNotifierProvider` と `encounterNotifierProvider` が別々に存在する理由が分かる

---

## 追加で読む価値がある（余裕ができたら）

| ファイル | 何を学べるか |
|---|---|
| `features/plaza/data/plaza_repository.dart` | バックエンドが「配列 or 単一オブジェクト」どちらで返しても壊れないパースの書き方 |
| `features/calendar/domain/calendar_notifier.dart` | 月内 30 日分の API を `Future.wait` で並列取得する例 |
| `features/mypage/data/achievement_repository.dart` | シンプルな追加機能を後付けする典型 |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Dart から `MethodChannel` でネイティブを叩く例（バッテリー最適化除外） |

---

## 今は読まなくていいファイル（理由付き）

| ファイル / パターン | 読まなくてよい理由 |
|---|---|
| `**/*.freezed.dart`, `**/*.g.dart` | **自動生成コード**。手で書かない・触らない。壊れたら `dart run build_runner build --delete-conflicting-outputs` で再生成 |
| `features/*/data/*_dummy_data.dart` | 開発初期のプレースホルダー。実 API 稼働後はほぼ使われていない |
| `features/mypage/presentation/mypage_screen.dart`（1056 行） | 巨大なフォーム画面。**マイページを改修する時に初めて開く**。全体理解には不要 |
| `features/calendar/presentation/calendar_screen.dart`（517 行） | UI 組み立てが中心。ロジックは `calendar_notifier.dart` に集約されているのでそちらだけでOK |
| `features/plaza/presentation/plaza_screen.dart`（747 行） | 同上。触る時に開けばよい |
| `features/*/presentation/widgets/*.dart` | 小さい UI 部品群。**該当画面を改修する時に必要になったものだけ**開く |
| `features/ble/ble_provider.dart` | 14 行しかなく、`ble_notifier.dart` の裏に隠れる補助定義。読まなくて困らない |
| `common/widgets/placeholder_screen.dart` | 開発時のダミー画面。本番では使われていない |

---

## 読み進めるコツ

1. **エラーになる呼び出しから逆に辿る**：`ref.read(xxxProvider)` を見たら、そのプロバイダー定義を Cmd+クリックで開いて読む
2. **`freezed.dart` `g.dart` は開かない**：500 行の自動生成コードは読む価値ゼロ。編集元 `.dart` だけ見る
3. **画面 1 つを追いかけ切る**：Home タブなら「router → home_screen → home_notifier → home_repository → dio_client」を一直線で読み切ってから次のタブへ
4. **図を横に置く**：`docs/diagrams/` の PNG を見ながら該当コードを読むと、抽象と実装が同時に頭に入る
5. **迷ったら質問**：`main_screen.dart` の BLE ライフサイクル管理はハマりどころ。詰まったら聞いて
