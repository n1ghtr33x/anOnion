import 'dart:io';
import 'package:flutter/material.dart';

Future<void> showSendPhotoWithTextDialog(
  BuildContext context, {
  required File photoFile,
  required Function(String text) onSend,
}) async {
  final textController = TextEditingController();

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.black87,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Верхняя панель с кнопкой "Отмена"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              // Фото
              Expanded(
                child: Image.file(
                  photoFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),

              // Текстовое поле + кнопка отправить
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Добавить сообщение...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        onSend(textController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Отправить'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
