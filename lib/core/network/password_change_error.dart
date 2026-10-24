import 'package:dio/dio.dart';

/// 認証トークンの失効とは区別する、パスワード変更時の入力エラー。
bool isIncorrectCurrentPassword(DioException error) {
  final data = error.response?.data;
  return error.requestOptions.method == 'PATCH' &&
      RegExp(r'^/users/[^/]+/password$').hasMatch(error.requestOptions.path) &&
      error.response?.statusCode == 401 &&
      data is Map &&
      data['error'] == 'current password is incorrect';
}
