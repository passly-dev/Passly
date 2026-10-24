import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/core/network/network_activity_provider.dart';
import 'package:syshack2026/core/network/password_change_error.dart';

/// セキュアストレージのプロバイダー（ユーザーID・認証トークン保存に使用）
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// 認証トークン(JWT)をセキュアストレージに保存する際のキー。
/// AuthRepository.login()で保存し、このファイルのインターセプターで読み出す。
const authTokenStorageKey = 'auth_token';

/// Dioインスタンスのプロバイダー
/// 2026-09-18: バックエンドがJWT認証に対応したため、Bearerトークンの自動付与と
/// 401(トークン期限切れ・不正)時の自動ログアウトを行うインターセプターを有効化した。
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // 実際のRenderデプロイURLに変更
      baseUrl: 'https://passly-backend-rjck.onrender.com',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 認証トークン自動付与 + 401時の自動ログアウト用インターセプター
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        startNetworkActivity(ref);
        final token = await ref
            .read(secureStorageProvider)
            .read(key: authTokenStorageKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        finishNetworkActivity(ref);
        handler.next(response);
      },
      onError: (error, handler) async {
        finishNetworkActivity(ref);
        if (error.response?.statusCode == 401 &&
            !isIncorrectCurrentPassword(error)) {
          // トークンが無効・期限切れの場合はセッションを破棄してログイン画面へ戻す
          // (AuthNotifier.logout()がストレージ削除+状態更新を行い、
          //  GoRouterのredirectが自動的に/loginへ遷移させる)
          await ref.read(authNotifierProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
