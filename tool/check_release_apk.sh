#!/usr/bin/env bash
# Sustainable-design gates over the BUILT release APK: size budget, merged-manifest
# permissions and effective minSdk. Reads the final artifact on purpose — plugins merge
# permissions and can raise minSdk, so the source manifest and Gradle config are not proof.
#
# Every threshold below ratchets one way only (smaller APK, lower minSdk, fewer
# permissions). Loosening one is a product-owner decision, never a build fix.
set -euo pipefail

readonly APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"

# Baseline 45.2 MiB (v0.1.0, universal APK, 3 ABIs) + ~15% headroom.
readonly MAX_MIB=53
# Old-device reach: a higher floor drops users off the app.
readonly MAX_MIN_SDK=26
# No networking, no background work, no boot hooks — see the privacy posture in the
# collection doc. ACCESS_NETWORK_STATE is merged in by androidx.media3 and stripped in
# android/app/src/main/AndroidManifest.xml; it is listed so it cannot come back silently.
readonly FORBIDDEN_PERMISSIONS=(
  android.permission.INTERNET
  android.permission.ACCESS_NETWORK_STATE
  android.permission.WAKE_LOCK
  android.permission.RECEIVE_BOOT_COMPLETED
)
# Matched as prefixes: FOREGROUND_SERVICE plus every FOREGROUND_SERVICE_* subtype.
readonly FORBIDDEN_PERMISSION_PREFIXES=(
  android.permission.FOREGROUND_SERVICE
)

failed=0

fail() {
  echo "::error::$1"
  failed=1
}

if [[ ! -f "$APK" ]]; then
  fail "no APK at $APK — build it before running this check"
  exit 1
fi

aapt2="$(find "${ANDROID_HOME:?ANDROID_HOME is not set}/build-tools" -name aapt2 -type f | sort -Vr | head -1)"
if [[ ! -x "$aapt2" ]]; then
  fail "aapt2 not found under $ANDROID_HOME/build-tools"
  exit 1
fi

# Size budget
bytes="$(stat -c %s "$APK")"
mib=$((bytes / 1024 / 1024))
echo "Release APK size: ${mib} MiB (${bytes} bytes), budget ${MAX_MIB} MiB"
if ((bytes > MAX_MIB * 1024 * 1024)); then
  fail "release APK is ${mib} MiB, over the ${MAX_MIB} MiB budget"
fi

badging="$("$aapt2" dump badging "$APK")"

# Merged-manifest permissions
permissions="$(printf '%s\n' "$badging" | sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p")"
echo "Merged permissions:"
printf '%s\n' "$permissions" | sed 's/^/  /'
while read -r permission; do
  [[ -n "$permission" ]] || continue
  for forbidden in "${FORBIDDEN_PERMISSIONS[@]}"; do
    if [[ "$permission" == "$forbidden" ]]; then
      fail "forbidden permission in the merged manifest: $permission"
    fi
  done
  for prefix in "${FORBIDDEN_PERMISSION_PREFIXES[@]}"; do
    if [[ "$permission" == "$prefix"* ]]; then
      fail "forbidden permission in the merged manifest: $permission"
    fi
  done
done <<<"$permissions"

# Effective minSdk
min_sdk="$(printf '%s\n' "$badging" | sed -n "s/^minSdkVersion:'\([0-9]*\)'/\1/p")"
echo "Effective minSdk: ${min_sdk:-unknown} (anchor ${MAX_MIN_SDK})"
if [[ -z "$min_sdk" ]]; then
  fail "could not read minSdkVersion from the APK"
elif ((min_sdk > MAX_MIN_SDK)); then
  fail "effective minSdk is $min_sdk, above the $MAX_MIN_SDK anchor"
fi

exit "$failed"
