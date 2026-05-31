import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VocabularyPicker extends StatelessWidget {
  final VoidCallback? onFilePicked;
  final String? currentFilePath;
  final double fontSize;

  const VocabularyPicker({
    super.key,
    this.onFilePicked,
    this.currentFilePath,
    this.fontSize = 14.0,
  });

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      onFilePicked?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = currentFilePath?.split('/').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '词库文件',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickFile(context),
          icon: const Icon(Icons.file_open),
          label: Text(
            fileName ?? '选择词库文件 (.txt)',
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 4),
          Text(
            '当前: $fileName',
            style: TextStyle(
              fontSize: fontSize * 0.85,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}
