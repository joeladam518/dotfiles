# Shell configuration files

My shell configuration files for Linux workstations, Mac workstations, and Linux servers. Supports both bash and zsh (oh-my-zsh).

## Structure

```
shell/
├── linux/
│   ├── .bashrc           ← bash entry point (symlink to ~/.bashrc)
│   ├── .zshrc            ← zsh entry point (symlink to ~/.zshrc)
│   ├── aliases.sh        ← sources shared + debian + dev aliases
│   └── functions.sh      ← sources shared + debian + dev functions
├── mac/
│   ├── .bash_profile     ← bash entry point (symlink to ~/.bash_profile)
│   ├── .zshrc            ← zsh entry point (symlink to ~/.zshrc)
│   ├── aliases.sh        ← sources shared + dev aliases + mac-specific
│   └── functions.sh      ← sources shared + dev functions + oda()
├── server/
│   ├── .bashrc           ← bash entry point (symlink to ~/.bashrc)
│   ├── aliases.sh        ← sources shared + debian aliases
│   └── functions.sh      ← sources shared + debian functions
└── shared/
    ├── aliases.sh        ← common aliases (both bash and zsh)
    ├── functions.sh      ← common functions (both bash and zsh)
    ├── dev_aliases.sh    ← git, sail aliases
    ├── dev_functions.sh  ← repo(), git branch helpers
    ├── debian_aliases.sh ← ls colors, dircolors (Linux only)
    └── debian_functions.sh ← auu(), showdns() (Linux only)
```

## Installation

Symlink the appropriate entry point(s) to your home directory:

```sh
# Linux (bash)
ln -sf ~/repos/dotfiles/shell/linux/.bashrc ~/.bashrc

# Linux (zsh)
ln -sf ~/repos/dotfiles/shell/linux/.zshrc ~/.zshrc

# Mac (bash)
ln -sf ~/repos/dotfiles/shell/mac/.bash_profile ~/.bash_profile

# Mac (zsh)
ln -sf ~/repos/dotfiles/shell/mac/.zshrc ~/.zshrc
```

## Bash

Platform entry points set `DOTFILES_DIR` and source their platform `aliases.sh` and `functions.sh`, which in turn source from `shared/`. Variables are unset at the end of the entry point.

## oh-my-zsh

### Prerequisites

#### Oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Third-party plugins

These plugins are listed in the `.zshrc` files but must be installed separately.

##### zsh-autosuggestions

**macOS:**
```sh
brew install zsh-autosuggestions
ln -s /opt/homebrew/share/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

**Ubuntu/Debian:**
```sh
sudo apt install zsh-autosuggestions
ln -s /usr/share/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

##### zsh-syntax-highlighting

**macOS:**
```sh
brew install zsh-syntax-highlighting
ln -s /opt/homebrew/share/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**Ubuntu/Debian:**
```sh
sudo apt install zsh-syntax-highlighting
ln -s /usr/share/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

##### you-should-use

Reminds you to use an alias when you type the full command.

```sh
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
```

##### zsh-bat

Wraps `cat` with [`bat`](https://github.com/sharkdp/bat) when bat is installed.

First install `bat`:

**macOS:**
```sh
brew install bat
```

**Ubuntu/Debian:**
```sh
sudo apt install bat
```

Then install the plugin:
```sh
git clone https://github.com/fdellwing/zsh-bat.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat
```

#### FZF for zsh

Run `fzf --zsh > ~/.fzf.zsh` (requires fzf ≥ 0.48).

### Plugins used

| Plugin | Purpose |
|--------|---------|
| `git` | git aliases + prompt info (replaces bash-git-prompt) |
| `fzf` | fzf key bindings + completions |
| `nvm` | lazy-loads nvm |
| `z` | jump to frecently-used directories |
| `zsh-autosuggestions` | fish-style inline suggestions |
| `zsh-syntax-highlighting` | colors valid/invalid commands |
| `you-should-use` | reminds you to use aliases |
| `zsh-bat` | wraps `cat` with `bat` |
