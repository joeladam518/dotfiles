# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## What This Is

A personal dotfiles repository containing shell configurations, editor settings, terminal configs, and utility scripts. Installed via symlinks to support three system types: `desktop`, `mac`, and `server`.

## Installation

```shell
sudo ./install.sh {desktop|mac|server}
sudo ./uninstall.sh {desktop|mac|server}
```

The install script symlinks bashrc, vimrc, vim plugins, and tmux config into `$HOME`. Git config is copied (not symlinked) for desktop/mac only. Existing `.bashrc` is preserved as `.bashrc.old`.

## Linting

```shell
pylint python/dotfiles/
```

There are no automated tests in this repository.

## Architecture

### Bash Configuration (`bashrc/`)

Platform-specific entry points source shared components:

- `bashrc/{desktop,server}/.bashrc` or `bashrc/mac/.bash_profile` — platform entry points
- `bashrc/shared/` — common aliases, functions, dev aliases, dev functions, debian aliases, debian functions
- Each platform directory also has its own `.bash_aliases` and `.bash_functions`

### Python CLI (`python/dotfiles/`)

A Python 3 CLI module invoked via `bin/dotfiles`. Uses argparse with subcommands:

- `dotfiles osinfo` — OS information
- `dotfiles install {composer|php}` — install dev tools
- `dotfiles uninstall {composer|php}` — uninstall dev tools
- `dotfiles repo` — manage repo directory aliases (reads `~/.repo-aliases`)

Entry point: `main.py:cli()`. Commands extend `cli.py:Command` base class.

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

## Code Style

- 4-space indentation (2-space for YAML)
- UTF-8, LF line endings
- Bash scripts use `set -Eeo pipefail`
- See `.editorconfig` for full rules
