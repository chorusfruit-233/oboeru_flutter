import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/tts_provider.dart';
import '../services/storage_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final vocabProv = context.watch<VocabularyProvider>();
    final aiProv = context.watch<AIProvider>();
    final ttsProv = context.watch<TTSProvider>();
    final settings = settingsProv.settings;
    final fontSize = settings.fontSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: settingsProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionTitle('学习设置', fontSize),
                _buildDailyWordsSlider(context, settings, settingsProv, fontSize),
                const Divider(height: 32),
                _buildSwitchTile(
                  context,
                  '随机顺序',
                  '打乱单词学习顺序',
                  settings.shuffle,
                  fontSize,
                  (v) => settingsProv.updateShuffle(v),
                ),
                const Divider(height: 32),
                _buildSwitchTile(
                  context,
                  '显示进度条',
                  '在页面中显示学习进度',
                  settings.showProgressBar,
                  fontSize,
                  (v) => settingsProv.updateShowProgressBar(v),
                ),
                const Divider(height: 32),

                _buildSectionTitle('词库管理', fontSize),
                _buildVocabPicker(context, vocabProv, settings, settingsProv, fontSize),
                const Divider(height: 32),

                _buildSectionTitle('外观', fontSize),
                _buildThemeSelector(context, settings, settingsProv, fontSize),
                const Divider(height: 32),
                _buildFontSizeSlider(context, settings, settingsProv, fontSize),
                const Divider(height: 32),

                _buildSectionTitle('AI 例句生成', fontSize),
                _buildAiSection(context, settings, settingsProv, aiProv, fontSize),
                const Divider(height: 32),

                _buildSectionTitle('语音朗读 (TTS)', fontSize),
                _buildTtsSection(context, settings, settingsProv, ttsProv, fontSize),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize * 1.1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDailyWordsSlider(
    BuildContext context,
    AppSettings settings,
    SettingsProvider prov,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('每日单词数: ${settings.dailyWords}', style: TextStyle(fontSize: fontSize)),
        Slider(
          value: settings.dailyWords.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: settings.dailyWords.toString(),
          onChanged: (v) => prov.updateDailyWords(v.round()),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    double fontSize,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: fontSize)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: fontSize * 0.85)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildVocabPicker(
    BuildContext context,
    VocabularyProvider vocabProv,
    AppSettings settings,
    SettingsProvider settingsProv,
    double fontSize,
  ) {
    final fileName = settings.vocabFilePath != null
        ? settings.vocabFilePath!.split('/').last
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                fileName ?? '未选择词库',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            TextButton.icon(
              onPressed: () => _pickVocabFile(context, vocabProv, settingsProv),
              icon: const Icon(Icons.file_open),
              label: Text('导入', style: TextStyle(fontSize: fontSize)),
            ),
          ],
        ),
        if (vocabProv.hasWords) ...[
          const SizedBox(height: 4),
          Text(
            '${vocabProv.allWords.length} 个单词已加载',
            style: TextStyle(fontSize: fontSize * 0.85, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Future<void> _pickVocabFile(
    BuildContext context,
    VocabularyProvider vocabProv,
    SettingsProvider settingsProv,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      await vocabProv.importAndLoad(result.files.single.path!);
      if (vocabProv.error == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('词库导入成功')),
        );
      }
    }
  }

  Widget _buildThemeSelector(
    BuildContext context,
    AppSettings settings,
    SettingsProvider prov,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主题模式', style: TextStyle(fontSize: fontSize)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'light', label: Text('浅色'), icon: Icon(Icons.light_mode)),
            ButtonSegment(value: 'dark', label: Text('深色'), icon: Icon(Icons.dark_mode)),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (v) => prov.updateThemeMode(v.first),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    AppSettings settings,
    SettingsProvider prov,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体大小: ${settings.fontSize.round()}', style: TextStyle(fontSize: fontSize)),
        Slider(
          value: settings.fontSize,
          min: 12,
          max: 24,
          divisions: 12,
          label: settings.fontSize.round().toString(),
          onChanged: (v) => prov.updateFontSize(v),
        ),
      ],
    );
  }

  Widget _buildAiSection(
    BuildContext context,
    AppSettings settings,
    SettingsProvider settingsProv,
    AIProvider aiProv,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('启用 AI 例句', style: TextStyle(fontSize: fontSize)),
          subtitle: Text(
            '通过 AI 自动生成单词例句',
            style: TextStyle(fontSize: fontSize * 0.85),
          ),
          value: settings.aiEnabled,
          onChanged: (v) {
            settingsProv.updateAiEnabled(v);
            aiProv.refreshSettings();
          },
            contentPadding: EdgeInsets.zero,
          ),
        if (settings.aiEnabled) ...[
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('预生成例句', style: TextStyle(fontSize: fontSize)),
            subtitle: Text(
              '开始学习时提前生成所有单词的 AI 例句',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
            value: settings.aiPreGenerate,
            onChanged: (v) => settingsProv.updateAiPreGenerate(v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'sk-...',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            obscureText: true,
            style: TextStyle(fontSize: fontSize),
            controller: TextEditingController(text: settings.aiApiKey)
              ..selection = TextSelection.collapsed(offset: settings.aiApiKey.length),
            onChanged: (v) => settingsProv.updateAiApiKey(v),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: '自定义 API 地址（可选）',
              hintText: 'https://api.openai.com',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            style: TextStyle(fontSize: fontSize),
            controller: TextEditingController(text: settings.aiCustomUrl)
              ..selection = TextSelection.collapsed(offset: settings.aiCustomUrl.length),
            onChanged: (v) => settingsProv.updateAiCustomUrl(v),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: '模型名称（可选）',
              hintText: 'gpt-4o-mini',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            style: TextStyle(fontSize: fontSize),
            controller: TextEditingController(text: settings.aiCustomModel)
              ..selection = TextSelection.collapsed(offset: settings.aiCustomModel.length),
            onChanged: (v) => settingsProv.updateAiCustomModel(v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: settings.aiDifficulty,
            decoration: InputDecoration(
              labelText: '难度',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(value: 'junior', child: Text('初级')),
              DropdownMenuItem(value: 'intermediate', child: Text('中级')),
              DropdownMenuItem(value: 'senior', child: Text('高级')),
            ],
            onChanged: (v) {
              if (v != null) settingsProv.updateAiDifficulty(v);
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text('自动生成例句', style: TextStyle(fontSize: fontSize)),
            subtitle: Text(
              '翻转卡片时自动生成例句',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
            value: settings.aiAutoGenerate,
            onChanged: (v) => settingsProv.updateAiAutoGenerate(v),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text('优先使用 AI 例句', style: TextStyle(fontSize: fontSize)),
            subtitle: Text(
              '即使词库有预置例句也优先显示 AI 生成的',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
            value: settings.aiPrefer,
            onChanged: (v) => settingsProv.updateAiPrefer(v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Text('最大 Token: ${settings.aiMaxTokens}',
              style: TextStyle(fontSize: fontSize * 0.85)),
          Slider(
            value: settings.aiMaxTokens.toDouble(),
            min: 100,
            max: 2000,
            divisions: 38,
            label: settings.aiMaxTokens.toString(),
            onChanged: (v) => settingsProv.updateAiMaxTokens(v.round()),
          ),
          DropdownButtonFormField<String>(
            value: settings.aiReasoningEffort,
            decoration: InputDecoration(
              labelText: '推理模式',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(value: 'disabled', child: Text('禁用推理')),
              DropdownMenuItem(value: 'low', child: Text('低 (快速)')),
              DropdownMenuItem(value: 'medium', child: Text('中')),
              DropdownMenuItem(value: 'high', child: Text('高 (深度思考)')),
            ],
            onChanged: (v) {
              if (v != null) settingsProv.updateAiReasoningEffort(v);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: aiProv.testing
                  ? null
                  : () => aiProv.testConnection(),
              icon: aiProv.testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find),
              label: Text(
                aiProv.testing ? '测试中...' : '测试连接',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
          if (aiProv.testResult != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: aiProv.testResult!.startsWith('连接成功')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: aiProv.testResult!.startsWith('连接成功')
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Text(
                aiProv.testResult!,
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  color: aiProv.testResult!.startsWith('连接成功')
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ],
        if (aiProv.generating)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildTtsSection(
    BuildContext context,
    AppSettings settings,
    SettingsProvider settingsProv,
    TTSProvider ttsProv,
    double fontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('启用语音朗读', style: TextStyle(fontSize: fontSize)),
          subtitle: Text(
            '学习时朗读单词和例句',
            style: TextStyle(fontSize: fontSize * 0.85),
          ),
          value: settings.ttsEnabled,
          onChanged: (v) => settingsProv.updateTtsEnabled(v),
          contentPadding: EdgeInsets.zero,
        ),
        if (settings.ttsEnabled) ...[
          const SizedBox(height: 4),
          Text(
            'Linux: espeak  |  macOS: say  |  Android/iOS: 系统 TTS',
            style: TextStyle(fontSize: fontSize * 0.75, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('自动朗读', style: TextStyle(fontSize: fontSize)),
            subtitle: Text(
              '翻转卡片时自动朗读单词',
              style: TextStyle(fontSize: fontSize * 0.85),
            ),
            value: settings.ttsAutoSpeak,
            onChanged: (v) => settingsProv.updateTtsAutoSpeak(v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: ttsProv.speaking
                  ? () => ttsProv.stop()
                  : () => ttsProv.speak('Hello, this is a test. '
                      'This is how your words will be pronounced.'),
              icon: Icon(ttsProv.speaking ? Icons.stop : Icons.volume_up),
              label: Text(
                ttsProv.speaking ? '停止' : '测试语音',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
