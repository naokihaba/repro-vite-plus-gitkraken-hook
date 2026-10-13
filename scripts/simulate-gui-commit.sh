#!/bin/sh
# Commit with the minimal environment that macOS gives to an app started from
# Finder or the Dock. Shell profile files are not read, thus PATH does not
# contain the directories of Node.js version managers.
#
# Usage: scripts/simulate-gui-commit.sh [--no-global-vp]
#   --no-global-vp  Also hide the global `vp` install (~/.vite-plus/bin).
set -u
cd "$(dirname "$0")/.." || exit 1

git_bin=$(command -v git)
vp_home=${VP_HOME-$HOME/.vite-plus}
[ "${1-}" = "--no-global-vp" ] && vp_home=/nonexistent

echo "// $(date +%s)" >> src/index.ts
git add src/index.ts

env -i HOME="$HOME" USER="${USER-}" VP_HOME="$vp_home" \
  PATH=/usr/bin:/bin:/usr/sbin:/sbin \
  "$git_bin" commit -m "test: commit with GUI-like environment"
code=$?
echo "git commit exit code: $code"
exit $code
