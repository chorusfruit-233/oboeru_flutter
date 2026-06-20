# AGENTS.md

Guidance for agent sessions in this Flutter repo. Complements `README.md`
(feature list + architecture tree, in Chinese).

## Project

Single-package Flutter app — no monorepo, no codegen, no DB. Dart SDK
`>=3.0.0 <4.0.0`; CI uses Flutter `stable`. State via `provider`; persistence
via JSON files + `SharedPreferences` (no SQLite/migrations).

## Developer commands (CI order)

    flutter pub get
    dart analyze        # CI runs `dart analyze`, NOT `flutter analyze`
    flutter test

Only one test file: `flutter test test/widget_test.dart`.
Release builds: `flutter build {linux,macos,windows,ios,web} --release`
or `flutter build apk --release`.

## Lint rules — do NOT "fix"

`analysis_options.yaml` deliberately DISABLES `prefer_const_constructors` and
`prefer_const_literals_to_create_immutables`. Do not add `const` to satisfy
linters — the project opted out on purpose.

## Linux build deps

CI installs: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`
(README omits `liblzma-dev` — include it). Linux TTS also needs the `espeak`
binary on PATH (see TTS).

## TTS — conditional export (important)

`lib/services/tts_service.dart` is a conditional-export barrel:

    export 'tts_service_stub.dart' if (dart.library.io) 'tts_service_impl.dart';

- Native (mobile/desktop) → `tts_service_impl.dart`
- Web → `tts_service_stub.dart`

Both define the same `TTSService` class. **Edit both files together or they
diverge.** The impl shells out via `Process.run` to `espeak` (Linux), `say`
(macOS), `powershell` + `System.Speech` (Windows), falling back to the
`flutter_tts` plugin on other native platforms (mobile). The stub (web) only
uses `flutter_tts`. All errors are swallowed (`catch (_)`).

## App entry & wiring

`lib/main.dart` calls `StorageService.instance.init()`
(`getApplicationDocumentsDirectory()`) BEFORE `runApp`, then registers 8
`ChangeNotifierProvider`s. `VocabularyProvider`, `FavoritesProvider`,
`SettingsProvider`, and `SrsProvider` auto-load on construction
(`..autoLoad()` / `..load()`).

Real home/shell is `lib/pages/app_shell.dart` (missing from README's tree).
`lib/app.dart` (`OboeruApp`) watches `SettingsProvider` for theme;
`AppSettings` defaults to `themeMode: 'light'`, `srsEnabled: true`.

Storage under app docs dir: `vocabulary/` (copied vocab files),
`progress.json`, `favorites.json`, `srs_state.json`, plus an AI example cache.
`progress.json` is day-scoped (cleared when not today); `srs_state.json` is
LONG-LIVED per-word SRS state — never day-clear it.

## Tests

Only `test/widget_test.dart`. It wraps `OboeruApp` in `MultiProvider` but does
NOT call `StorageService.instance.init()` or `.load()` on providers (unlike
`main.dart`) — it relies on `AppSettings` defaults and pumps once. Follow the
same lightweight pattern, or explicitly init storage if your test needs
persistence.

`test/srs_algorithm_test.dart` is a pure-Dart unit test (no Flutter bindings)
for the SM-2 math in `lib/services/srs_algorithm.dart`. Prefer this style for
logic with no widget deps. Run one file: `flutter test test/srs_algorithm_test.dart`.

## SRS — spaced repetition engine

`lib/services/srs_algorithm.dart` is pure SM-2 (no Flutter import): per-word
`repetition`/`interval`/`easinessFactor` (clamped [1.3, 2.5]), quality
`again/hard/good/easy` → q 0/3/4/5, interval ladder 1→6→round(prev·EF).
`lib/services/srs_service.dart` persists `Map<String, SrsCard>` to
`srs_state.json` and builds the daily queue (due reviews first, then new words
within the `dailyWords` budget capped by `newCardsPerDay`).
`lib/providers/srs_provider.dart` drives the session.

`srsEnabled=false` → `LearningPage` uses the legacy random-pick + browse flow
(`LearningProvider`); the SRS rating buttons and queue are skipped. Quiz
results feed SRS (`correct`→`good`, `wrong`→`again`) only when `srsEnabled`.

## Vocabulary format

`VocabularyService.loadFromFile` dispatches on extension:
- `.json` — accepts either a bare `[...]` array or `{"words": [...]}`.
- `.txt` — tab-separated, parsed via `Word.fromLine`; `#`-prefixed lines skipped.

Adding a new field/format means updating `Word` (`lib/models/word.dart`) AND
`VocabularyService`.

## Dependencies worth knowing

- `file_picker` is intentionally pinned `>=10.0.0 <11.0.0`; dependabot is
  configured to ignore 11.x. Don't bump past 10.
- AI examples use the `http` package directly against an OpenAI-compatible
  endpoint (no SDK); custom base URL supports Ollama-style servers.
  `reasoning_effort` is sent when enabled.

## CI / release

- `build.yml` (push/PR → `main`): the `analyze` job
  (`pub get` → `dart analyze` → `flutter test`) GATES 6 parallel platform
  builds. Keep analyze + test green or nothing builds.
- `release.yml` is MANUAL (`workflow_dispatch`): optional version tag
  (e.g. `v1.0.0`) → per-platform builds → GitHub Release. Android uses
  `--split-per-abi`.
- Android release signing uses secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
  `KEY_ALIAS`, `KEY_PASSWORD` → `android/upload-keystore.jks` +
  `android/key.properties`. Without them the build runs unsigned.
  `*.jks`/`*.keystore` are gitignored.
