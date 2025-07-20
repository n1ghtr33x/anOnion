import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      // Запрос разрешений
      if (Platform.isAndroid || Platform.isIOS) {
        final permission = await Permission.photos.request();
        if (!permission.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нет доступа к фото')),
          );
          return;
        }
      }

      // Скачиваем файл во временное хранилище
      final dir = await getTemporaryDirectory();
      final filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${dir.path}/$filename';

      await Dio().download(imageUrl, filePath);

      // Сохраняем в галерею
      await Gal.putImage(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото сохранено в галерею')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () => _downloadImage(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
