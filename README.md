# vp-gitkraken-hook-repro

Minimal repository to reproduce a Vite+ Git hook failure that occurs only when
the commit is made from GitKraken (or another GUI Git client).

## Setup

```sh
vp install   # runs `vp config`, which sets core.hooksPath to .vite-hooks/_
vp hooks status
```

## Reproduce with GitKraken

1. Start GitKraken from Finder or the Dock (not from a terminal).
2. Open this repository.
3. Change `src/index.ts`, stage the change, and commit.
4. Copy the full hook output from the GitKraken error dialog.

`.vite-hooks/pre-commit` prints lines that start with `[repro]`. These lines
show the `PATH`, `node`, `vp`, and `git` that the client gives to the hook.

## Reproduce without GitKraken

An app started from Finder or the Dock does not read shell profile files.
`scripts/simulate-gui-commit.sh` commits with that minimal environment.

```sh
scripts/simulate-gui-commit.sh                  # global vp is visible
scripts/simulate-gui-commit.sh --no-global-vp   # global vp is hidden
```

| Command                                         | Result on macOS, vite-plus 1.1.0 |
| ----------------------------------------------- | -------------------------------- |
| `git commit` in a terminal                      | Passes                           |
| `scripts/simulate-gui-commit.sh`                | Passes                           |
| `scripts/simulate-gui-commit.sh --no-global-vp` | Fails with exit code 127         |

Output of the failing case:

```
./node_modules/.bin/vp: line 20: exec: node: not found
VITE+ - pre-commit script failed (code 127)
VITE+ - command not found in PATH=./node_modules/.bin:<git exec path>:/usr/bin:/bin:/usr/sbin:/sbin
```

The dispatcher finds `node_modules/.bin/vp`, but that wrapper needs `node` in
`PATH`. The dispatcher adds `~/.vite-plus/bin` (or `$VP_HOME/bin`) to `PATH`.
If that directory does not exist, and Node.js comes from a version manager
that is set up only in a shell profile, `node` is not found.

This result is from the simulation. It is not confirmed in GitKraken.
