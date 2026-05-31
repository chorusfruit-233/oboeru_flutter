# Oboeru — AI 智能背单词

跨平台 Flutter 单词学习应用，支持 **AI 例句生成**（OpenAI 兼容 API）、**TTS 语音朗读**（Linux/macOS/Windows 本地引擎 + 移动端系统 TTS）、**现代化 JSON 词库格式**、**错题复习**等。

## 特性

- **AI 例句生成** — 对接 OpenAI 兼容 API（支持自定义 URL/模型），自动生成英文例句并附带中文翻译
- **TTS 语音朗读** — Linux(eSpeak)、macOS(say)、Windows(SAPI)、移动端系统 TTS，支持自动朗读和例句朗读
- **现代化词库** — JSON 格式词库（含发音、例句、词性、标签），同时兼容旧版 tab-separated txt 格式
- **测验 + 错题复习** — 随机选项测验，自动收集错题，支持闪卡式复习
- **收藏夹** — 生词收藏，支持按时间/字母排序
- **设置丰富** — 每日词量、随机顺序、字体大小、深浅主题、进度条
- **AI 配置灵活** — API Key、自定义端点、模型、难度、最大 Token、推理模式、预生成、优先 AI 例句
- **全平台** — Linux / macOS / Windows / Android / iOS / Web

## 技术架构

```
lib/
├── main.dart              # 入口，Provider 注册
├── app.dart               # MaterialApp 主题
├── models/                # 数据模型
│   ├── word.dart          #   单词（支持 JSON + txt 双格式）
│   ├── settings.dart      #   应用设置
│   └── user_progress.dart #   学习进度
├── services/              # 服务层
│   ├── ai_service.dart    #   OpenAI 兼容 API
│   ├── tts_service.dart   #   跨平台 TTS（条件导出）
│   ├── vocabulary_service.dart  # 词库加载、每日选词、选项生成
│   ├── storage_service.dart     # 文件 I/O
│   ├── settings_service.dart    # SharedPreferences
│   ├── favorites_service.dart   # 收藏持久化
│   ├── progress_service.dart    # 进度持久化
│   └── example_cache_service.dart  # AI 例句缓存
├── providers/             # 状态管理（Provider）
│   ├── ai_provider.dart
│   ├── tts_provider.dart
│   ├── vocabulary_provider.dart
│   ├── learning_provider.dart
│   ├── quiz_provider.dart
│   ├── favorites_provider.dart
│   └── settings_provider.dart
├── pages/                 # 页面
│   ├── home_page.dart     #   首页
│   ├── learning_page.dart #   单词学习闪卡
│   ├── quiz_page.dart     #   测验
│   ├── review_page.dart   #   错题复习
│   ├── favorites_page.dart
│   └── settings_page.dart #   设置（含 AI/TTS 配置）
└── widgets/               # 组件
    ├── word_card.dart     #   闪卡（发音、例句、TTS 按钮）
    ├── option_button.dart #   测验选项按钮
    └── progress_bar_widget.dart
```

## 构建运行

### 依赖

- Flutter ≥3.0.0
- Linux: `clang cmake ninja-build pkg-config libgtk-3-dev`
- Linux TTS: `espeak` 包（可选）

### 本地运行

```bash
flutter pub get
flutter run -d linux
```

### CI/CD

| Workflow | 触发 | 说明 |
|----------|------|------|
| `Build All Platforms` | push/PR → main | 自动分析 + 6 平台并行构建 |
| `Manual Release` | 手动触发 | 选择平台 + 可选版本 tag → GitHub Release |

## 词库格式

### JSON（推荐）

```json
{
  "name": "词库名",
  "language": "en",
  "words": [
    {
      "word": "apple",
      "pronunciation": "/ˈæp.əl/",
      "pos": "n.",
      "meaning": "苹果",
      "example": "I eat an apple every day.",
      "exampleMeaning": "我每天吃一个苹果。",
      "tag": "food",
      "difficulty": 1
    }
  ]
}
```

### TXT（兼容）

```
word	pos	meaning	wrongOptions1,wrongOptions2
apple	n.	苹果
cat	n.	猫	cart,cut,cap
```

## 设置说明

| 设置项 | 说明 |
|--------|------|
| AI 例句 | 对接 OpenAI 兼容 API，支持 `https://api.openai.com` 或自定义端点（如 Ollama `http://localhost:11434`） |
| 推理模式 | `reasoning_effort` 参数，禁用可减少 token 消耗 |
| 预生成例句 | 开始学习时提前生成所有单词的 AI 例句 |
| TTS | Linux(eSpeak) / macOS(say) / Windows(SAPI) / 移动端系统 TTS |

## 许可

MIT
