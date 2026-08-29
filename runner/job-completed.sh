#!/usr/bin/env bash
# Remove only the repository workspace for the completed job. Runner tool,
# action, diagnostic, and update caches under _work are intentionally retained.
set -u

workspace="${GITHUB_WORKSPACE:-}"
if [[ -z "$workspace" ]]; then
  exit 0
fi

repo_root="$(dirname "$workspace")"
case "$repo_root" in
  /home/anvil/runners/*/_work/*)
    ;;
  *)
    echo "Refusing to clean unexpected workspace: $repo_root" >&2
    exit 0
    ;;
esac

if rm -rf --one-file-system -- "$repo_root" 2>/dev/null; then
  exit 0
fi

# A non-root user inside rootless Docker maps to a subordinate host UID. The
# narrow wrapper accepts only this browser runner's first-level repository root.
if sudo -n /usr/local/sbin/intuitum-browser-reclaim "$repo_root" 2>/dev/null; then
  rm -rf --one-file-system -- "$repo_root" 2>/dev/null || true
fi

exit 0
