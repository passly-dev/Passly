import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/auth/data/auth_repository.dart';

/// 認証状態を管理するプロバイダー
/// ログイン中のユーザー情報を保持し、null = 未ログインを意味する
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

/// 認証状態の管理を行うNotifier
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() async {
    // アプリ起動時にセッションの存在をチェックする
    final repo = ref.read(authRepositoryProvider);
    final hasSession = await repo.hasSession();
    if (!hasSession) return null;

    // セッションがあればユーザー情報を復元する
    final userId = await repo.getSavedUserId();
    if (userId == null) return null;

    try {
      return await repo.restoreSession(userId);
    } catch (_) {
      // ユーザー情報取得に失敗した場合は未ログインとする
      return null;
    }
  }

  /// ログイン処理（メールアドレスで認証）
  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email: email, password: password);
    });
  }

  /// サインアップ処理
  Future<void> signUp({
    required String id,
    required String name,
    required String email,
    required String password,
    String? role,
    String? connpassUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(
        id: id,
        name: name,
        email: email,
        password: password,
        iconUrl: "", // 仕様書で必須のため空文字を送信
        oneWord: "",
        role: role ?? "other",
        techStack: "",
        connpassUrl: connpassUrl ?? "",
      );
      // signUpのレスポンスがないため、直後に自動ログイン処理を呼び出してセッションを確立します
      return await repo.login(email: email, password: password);
    });
  }

  /// 保存済み userId から最新のユーザー情報を取り直す (プロフィール編集後などに使用)。
  Future<void> refresh() async {
    final repo = ref.read(authRepositoryProvider);
    final userId = await repo.getSavedUserId();
    if (userId == null) return;
    state = await AsyncValue.guard(() => repo.restoreSession(userId));
  }

  /// ログアウト処理
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncValue.data(null);
  }

  /// 現在のユーザーIDを取得する
  String? get currentUserId => state.value?.id;
}
