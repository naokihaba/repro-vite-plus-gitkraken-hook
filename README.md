# repro-vite-plus-gitkraken-hook

Minimal repository to examine a report that a Vite+ Git hook fails only when
the commit is made from GitKraken.

**Status: not reproduced.** A commit from GitKraken 12.6.0 on macOS passes.

## Setup

```sh
vp install   # runs `vp config`, which sets core.hooksPath to .vite-hooks/_
vp hooks status
```

## Test with GitKraken

1. Start GitKraken from Finder or the Dock (not from a terminal).
2. Open this repository.
3. Change `src/index.ts`, stage the change, and commit.
4. Read `.git/repro-hook.log`.

`.vite-hooks/pre-commit` writes lines that start with `[repro]` to stderr and
to `.git/repro-hook.log`. These lines show the `PATH`, `node`, `vp`, and `git`
that the client gives to the hook. GitKraken shows only "Hook process exited."
when the hook passes, thus the log file is necessary.

## Result

| Item           | Value                                                 |
| -------------- | ----------------------------------------------------- |
| OS             | macOS (Darwin 27.0.0)                                 |
| GitKraken      | 12.6.0                                                |
| vite-plus      | 1.1.0                                                 |
| Hook           | `pre-commit` with `vp staged`                         |
| Commit result  | Passes                                                |

GitKraken was started with `PATH=/usr/bin:/bin:/usr/sbin:/sbin`, which is the
environment of an app started from Finder or the Dock. The hook log shows:

- `PATH` contains the directories from the shell profile (for example
  `/opt/homebrew/bin` and `~/.vite-plus/bin`). The GitKraken process did not
  have these directories. GitKraken thus seems to load the shell environment
  before it runs a hook.
- `node` is found, thus `node_modules/.bin/vp` starts.
- `git` is the Git that GitKraken supplies (2.54.0), not the system Git.
- `core.hooksPath` (`.vite-hooks/_`) is used correctly.

## Simulation without GitKraken

`scripts/simulate-gui-commit.sh` commits with a minimal `PATH` and does not
load the shell environment.

```sh
scripts/simulate-gui-commit.sh                  # global vp is visible: passes
scripts/simulate-gui-commit.sh --no-global-vp   # global vp is hidden: fails, exit code 127
```

The failing case prints `exec: node: not found`. GitKraken 12.6.0 on macOS
does not give this environment to a hook, thus this failure does not explain
the report. The script can be useful for a Git client that does not load the
shell environment.

## Conditions that are not tested

- Windows and Linux.
- Older GitKraken versions.
- A Node.js version manager that selects the version for each directory
  (for example mise, fnm, or asdf).
- A hook that runs commands other than `vp staged`.

## Information to collect from a failing machine

- OS and GitKraken version.
- How Node.js and `vp` are installed.
- The full hook output from GitKraken.
- The content of `.git/repro-hook.log` after a commit in this repository.
