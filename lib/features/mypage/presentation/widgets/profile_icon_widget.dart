import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

/// 円形のプロフィール写真と、画像アップロード用のカメラボタンを含むWidget
class ProfileIconWidget extends StatelessWidget {
  final String? imagePath; // ローカルファイルパス
  final String? imageUrl; // Firebase URL
  final ValueChanged<String> onImageSelected;

  const ProfileIconWidget({
    super.key,
    this.imagePath,
    this.imageUrl,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // ギャラリーから画像を選択
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // 写真部分
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0x263AAA3A), // #3AAA3Aの15%透明度
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImageWidget(),
          ),
          // 編集ボタン（右下）
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Firebase URLが優先、次にローカルパス、両方がない場合はデフォルトアイコン
  Widget _buildImageWidget() {
    // Firebase URL が存在する場合（NULL や空文字をチェック）
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image load error: $error');
          return const Icon(Icons.person, color: AppColors.primary, size: 48);
        },
      );
    }

    // ローカルパスが存在する場合（NULL や空文字をチェック）
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Local file error: $error');
          return const Icon(Icons.person, color: AppColors.primary, size: 48);
        },
      );
    }

    // どちらもない場合
    return const Icon(Icons.person, color: AppColors.primary, size: 48);
  }
}
