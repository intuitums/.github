#!/bin/sh
# Biweekly prune of cargo build caches under every GitHub Actions runner's
# _work on this host. Two guards: a runner with a job in flight (a
# Runner.Worker process for its user) is skipped, and only directories named
# target that contain cargo's CACHEDIR.TAG marker are removed — build outputs
# only, never arbitrary files that happen to be called "target".
set -u
for unit in $(systemctl list-units --type=service --state=running --no-legend |
              awk '{print $1}' | grep '^actions\.runner\.'); do
  user=$(systemctl show "$unit" -p User --value)
  dir=$(systemctl show "$unit" -p WorkingDirectory --value)
  [ -n "$user" ] && [ -n "$dir" ] || continue
  if pgrep -u "$user" -f Runner.Worker >/dev/null 2>&1; then
    echo "$unit: job in flight, skipping"
    continue
  fi
  targets=$(find "$dir/_work" -maxdepth 4 -type d -name target \
            -exec test -f '{}/CACHEDIR.TAG' \; -print 2>/dev/null)
  [ -n "$targets" ] || continue
  echo "$unit: pruning:"
  echo "$targets" | sed 's/^/  /'
  echo "$targets" | while IFS= read -r t; do rm -rf "$t"; done
done
