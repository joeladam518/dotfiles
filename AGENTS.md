# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## What This Is

A personal dotfiles repository containing shell configurations, editor settings, terminal configs, and utility scripts. Installed via symlinks to support three system types: `linux`, `mac`, and `server`.

## Installation

The install script is self-bootstrapping — it clones the repo to `~/repos/dotfiles` if not already present, then re-execs from there.

```shell
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh) [--bash|--zsh] [-e {linux|mac|server}]
```

Or manually:

```shell
./install.sh [--bash|--zsh] [-e {linux|mac|server}]
./uninstall.sh [--bash|--zsh] [-e {linux|mac|server}]
```

The environment (`linux`, `mac`, `server`) is detected automatically via `uname` and `systemctl get-default`. Use `-e`/`--env` to override. Shell defaults to bash; pass `--zsh` for zsh. The install script symlinks the rc file, vimrc, vim plugins, and tmux config into `$HOME`. Git config is copied (not symlinked) for linux/mac only. Existing rc files are preserved as `.bashrc.old` / `.zshrc.old`. Re-running install on a machine with a stale symlink (e.g. from an old `bashrc/` path) will automatically update it to the new `shell/` location.

## Linting

```shell
pylint python/dotfiles/
```

There are no automated tests in this repository.

## Architecture

### Shell Configuration (`shell/`)

Platform-specific entry points source shared components. Both bash and zsh configs live together per platform:

```
shell/
├── linux/     — .bashrc, .zshrc, aliases.sh, functions.sh
├── mac/       — .bash_profile, .zshrc, aliases.sh, functions.sh
├── server/    — .bashrc, aliases.sh, functions.sh
└── shared/    — aliases.sh, functions.sh, dev_aliases.sh, dev_functions.sh,
                 debian_aliases.sh, debian_functions.sh
```

- `shell/{linux,server}/.bashrc` or `shell/mac/.bash_profile` — bash entry points
- `shell/{linux,mac}/.zshrc` — zsh entry points (oh-my-zsh)
- `shell/shared/` — common aliases and functions sourced by all platforms and both shells

### Python CLI (`python/dotfiles/`)

A Python 3 CLI module invoked via `bin/dotfiles`. Uses argparse with subcommands:

- `dotfiles osinfo` — OS information
- `dotfiles install php [version]` — install PHP (with optional `--composer [DIR]`)
- `dotfiles uninstall php [version]` — uninstall PHP (with optional `--composer`)
- `dotfiles repos` — manage repo directory aliases (reads `~/.repo-aliases`)

Entry point: `main.py:cli()`. Uses argparse's `set_defaults(handler=fn)` idiom — each
subcommand is a plain function `def cmd_X(args: Namespace) -> None`. No base classes.

To add a new command:
1. In the command's module, place `_configure_parser(p)` and `add_parser(subparsers)`
   **directly above** the `cmd_X(args)` handler function they belong to.
2. Call `add_parser(subparsers)` from `main.py:_build_parser()` to register it.

See `python/dotfiles/README.md` for a full example.

Key files: `main.py` (parser + dispatch), `php.py` (install/uninstall + composer),
`repos.py` (repo aliases), `osinfo.py` (OS detection helpers), `utils.py` (shared helpers).

### Utility Scripts (`bin/`)

Executable scripts added to `$PATH` by the bashrc files:

- `cmsg` — colorized terminal messages
- `dkr` — Docker helper
- `dotfiles` — Python CLI wrapper
- `proxify` — proxy configuration
- `transMP4grify` — video conversion for Jira uploads

### Config Files

- `git/.gitconfig` + `git/themes.gitconfig` — git config with delta diff theme
- `vimrc/.vimrc` — Vim config using vim-plug (PaperColor theme, FZF, polyglot)
- `tmux/.tmux.conf` — tmux with `Ctrl+a` prefix, vim-style navigation
- `terminals/.alacritty.toml` — Alacritty terminal config

## User Preferences

- **Git prompt**: Prefer `bash-git-prompt` (`$HOME/.bash-git-prompt/gitprompt.sh`) over any native zsh solution (e.g. `vcs_info`, oh-my-zsh `git-prompt` plugin). Do not replace or suggest replacing it.

## Code Style

- 4-space indentation (2-space for YAML)
- UTF-8, LF line endings
- Bash scripts use `set -Eeo pipefail`
- See `.editorconfig` for full rules
