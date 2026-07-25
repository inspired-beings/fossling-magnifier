#!/usr/bin/env bash
# Security gate: refuse to ship while any readable security surface has an open alert.
#
# GITHUB_TOKEN can read code-scanning alerts (`permissions: security-events: read`), but
# Actions has no permission key for the secret-scanning or Dependabot alert APIs — those
# answer 403 unless GH_TOKEN carries a PAT/App token holding the matching fine-grained
# permission. A surface this token cannot read is reported loudly as NOT GATED; it is
# never skipped quietly.
set -euo pipefail

readonly REPOSITORY="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is not set}"
readonly SURFACES=(code-scanning secret-scanning dependabot)

failed=0
ungated=()

for surface in "${SURFACES[@]}"; do
  # On success `count` is the number of open alerts, on failure the gh error output.
  if ! count="$(gh api "repos/$REPOSITORY/$surface/alerts?state=open&per_page=100" --jq 'length' 2>&1)"; then
    message="$(printf '%s' "$count" | tr '\n' ' ')"
    status="$(printf '%s' "$count" | sed -n 's/.*(HTTP \([0-9]\{3\}\)).*/\1/p' | tail -1)"
    # 403/404: the surface is off or out of this token's reach. Anything else (401, 5xx)
    # is a broken setup — a release must not sail through on it.
    case "$status" in
    403 | 404)
      ungated+=("$surface")
      echo "::warning::$surface alerts NOT GATED — this token cannot read them: $message"
      ;;
    *)
      echo "::error::$surface alerts could not be read (HTTP ${status:-?}): $message"
      failed=1
      ;;
    esac
    continue
  fi

  if ((count > 0)); then
    echo "::error::$surface: $count open alert(s) — resolve them before releasing"
    failed=1
  else
    echo "$surface: no open alerts"
  fi
done

if ((${#ungated[@]} > 0)); then
  echo "::warning::not gated on ${ungated[*]} — grant a token with those read permissions to close the gap"
fi

exit "$failed"
