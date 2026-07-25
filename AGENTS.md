# Fossling Magnifier — agent guide

Flutter camera magnifier for low-vision users. Android-first, offline, adless, AGPL-3.0.

## Toolchain

mise-managed (`mise.toml`): Flutter, Java, Android SDK. Never install these system-wide.

```bash
mise install
eval "$(mise activate bash)"
```

- `flutter analyze` — must be clean.
- `flutter test` — whole suite; `flutter test <path>` for one file.
- `flutter gen-l10n` — after editing an `.arb` (`flutter pub get` also regenerates).
- `adb devices && flutter run` — real device only, no emulator.

Full first-clone setup (SDK licenses, platform packages): `CONTRIBUTING.md`.

## Architecture

- Feature-based: `lib/screens/`, `lib/features/<feature>/components/`, plus `libs/`,
  `helpers/`, `utils/` global or per-feature. `types.dart` / `constants.dart` for types and
  constants.
- One class or function per file.
- Hardware sits behind `MagnifierCamera` (`lib/features/magnifier/libs/`);
  `PluginMagnifierCamera` is the real implementation, `FakeMagnifierCamera`
  (`test/helpers/`) the test double. NEVER touch camera plugins in unit tests.
- L10n source `.arb` in `lib/l10n/` (en + fr); generated output is gitignored.

## Accessibility harness (non-negotiable)

- EVERY reachable screen state MUST be registered in the `_screenStates` map of
  `test/a11y/accessibility_guidelines_test.dart` — it runs the Material tap-target,
  labeled-tap and text-contrast guidelines over every state × locale (en + fr). An
  unregistered state is exactly the failure this suite exists to catch.
- Add the same state to `test/a11y/text_scaling_test.dart` — it must stay usable (controls
  found, no overflow) at font scale 1.0/1.3/2.0× on a 320×568 viewport.
- Theme lives in `lib/libs/build_app_theme.dart` and is shared with the tests so contrast is
  checked against shipped colors — NEVER inline theme colors in widgets.
- Icon-only buttons: wrap in `MergeSemantics(Semantics(...))` so label and tap action share
  one node.

## Sustainable-design gate

`tool/check_release_apk.sh` runs in CI (`release-apk` job) against the BUILT release APK:
size budget 53 MiB (ratchet-down-only), forbidden merged manifest permissions (INTERNET,
ACCESS_NETWORK_STATE, WAKE_LOCK, FOREGROUND_SERVICE*, RECEIVE_BOOT_COMPLETED), effective
minSdk ≤ 26. Plugins merge permissions in — strip unwanted ones with `tools:node="remove"`
in `android/app/src/main/AndroidManifest.xml`, never by loosening the gate. Raising any
threshold is a product decision, not a build fix.

## Security gate

`tool/check_security_alerts.sh` (CI `security-alerts` job, and a release gate) fails on any
open code-scanning / secret-scanning / Dependabot alert. Open alerts are blockers.

## Store metadata

`fastlane/metadata/android/{en-US,fr-FR}/` is the single source of truth for Play and
F-Droid. en-US `full_description.txt` is the MASTER copy and `README.md` mirrors it — a PR
touching one updates the other. Changelogs are keyed by versionCode
(`changelogs/<versionCode>.txt`).

## Git

- Conventional Commits (Angular): `<type>(<scope>): <subject>`.
- Every commit signed off — `git commit -s` (DCO check blocks unsigned PRs).
- Squash-merge only; `main` is linear and protected.
- Third-party GitHub Actions pinned to commit SHAs.
