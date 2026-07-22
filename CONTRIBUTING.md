# Contributing

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Install](#install)
  - [Run](#run)
  - [Test](#test)
- [Code of Conduct](#code-of-conduct)
- [Commit Message Format](#commit-message-format)
- [Developer Certificate of Origin](#developer-certificate-of-origin)

---

## Getting Started

### Requirements

- [mise](https://mise.jdx.dev)
- An Android phone with USB debugging enabled (no emulator needed)

### Install

```bash
mise install
eval "$(mise activate bash)"   # or your shell
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-36" "build-tools;28.0.3"
flutter pub get
```

`flutter pub get` also generates the localization sources (`lib/l10n/generated/`, gitignored) via `generate: true` in `pubspec.yaml` — no separate step needed on a fresh clone. Run `flutter gen-l10n` directly only if you edit an `.arb` file under `lib/l10n/` and want the generated output refreshed without a full `pub get`.

### Run

```bash
adb devices        # phone must show as 'device'
flutter run
```

### Test

```bash
flutter analyze
flutter test                                  # whole suite
flutter test test/path/to/file_test.dart      # single file
```

## Code of Conduct

Help us keep this project open and inclusive. Please read and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## Commit Message Format

This repository follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification and
specificaly the [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit).

## Developer Certificate of Origin

All commits must be signed off with `git commit -s`, which adds a `Signed-off-by` line certifying the
[Developer Certificate of Origin](https://developercertificate.org): you wrote the contribution, or otherwise
have the right to submit it under this project's license.

A CI check blocks pull requests containing unsigned commits. If you forgot to sign off:

- Last commit: `git commit --amend --signoff`
- Whole branch: `git rebase --signoff <base-branch>`
