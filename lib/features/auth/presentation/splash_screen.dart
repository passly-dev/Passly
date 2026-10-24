import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/core/network/network_activity_provider.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/encounter/domain/encounter_notifier.dart';

/// スプラッシュ画面Widget
/// 2秒間ロゴを表示した後、認証状態に応じて適切な画面へ遷移する
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // フェードインアニメーションの設定
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Renderの無料枠はスリープするため、起動時にウェイクアップリクエストを送る
    _wakeUpServer();

    // 2秒後に遷移先を判定する
    _navigateAfterDelay();
  }

  /// サーバーにウェイクアップリクエストを送信（Renderスリープ対策）
  Future<void> _wakeUpServer() async {
    try {
      final dio = ref.read(dioProvider);
      // ヘルスチェックエンドポイントまたはルートにリクエストを送る
      // エラーは無視（サーバーが起きればOK）
      await dio
          .get('/')
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('timeout'),
          );
      debugPrint('Server wake-up request sent');
    } catch (e) {
      // エラーは無視（ウェイクアップが目的なので）
      debugPrint('Server wake-up: $e (ignored)');
    }
  }

  /// 2秒待機後、初回の認証状態チェックを開始する
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _checkAuthState();
  }

  /// 認証状態をポーリングでチェックし、ログインまたは結果待ちへと遷移する
  void _checkAuthState() {
    final authState = ref.read(authNotifierProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          // ログイン済み → 未確認すれ違いデータをチェック
          _checkPendingEncounters();
        } else {
          // 未ログイン → ログイン画面
          enableNetworkActivity(ref);
          context.go('/login');
        }
      },
      loading: () {
        // まだ認証チェック中なら待って再帰（ここで2秒待機をスタックさせない）
        Future.delayed(const Duration(milliseconds: 500), _checkAuthState);
      },
      error: (_, _) {
        // エラー時はログイン画面へ
        enableNetworkActivity(ref);
        context.go('/login');
      },
    );
  }

  /// 未確認のすれ違いデータをチェックし、結果画面またはホームへ遷移する
  /// APIが未実装やエラーの場合は安全にホーム画面へフォールバック
  void _checkPendingEncounters() {
    try {
      final encounterState = ref.read(encounterNotifierProvider);
      encounterState.when(
        data: (encounters) {
          if (encounters.isNotEmpty) {
            // 未確認データあり → すれ違い結果画面
            enableNetworkActivity(ref);
            context.go('/encounter-result');
          } else {
            // 未確認データなし → ホーム画面
            enableNetworkActivity(ref);
            context.go('/home');
          }
        },
        loading: () {
          // ロード中なら待って再帰（最大5秒でタイムアウト）
          Future.delayed(
            const Duration(milliseconds: 500),
            _checkPendingEncounters,
          );
        },
        error: (_, _) {
          // エラー時は安全にホームへ（APIが未実装でも問題なし）
          debugPrint('未確認データの取得でエラー発生、ホーム画面へ遷移');
          enableNetworkActivity(ref);
          context.go('/home');
        },
      );
    } catch (e) {
      // プロバイダー自体のエラーもキャッチしてホーム画面へ
      debugPrint('encounter チェック中にエラー: $e');
      enableNetworkActivity(ref);
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: FadeTransition(opacity: _fadeAnimation, child: _buildLogo()),
      ),
    );
  }

  /// ロゴ部分の構築
  Widget _buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // アプリアイコン
        Image.asset('assets/images/app_icon.png', width: 100, height: 100),
        const SizedBox(height: 24),
        const Text(
          'Passly',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'すれ違いで、つながる',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
