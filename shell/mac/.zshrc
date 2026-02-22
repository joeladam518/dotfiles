# -*- shell-script -*-
# ~/.zshrc: executed by zsh(1) for interactive shells on macOS

DOTFILES_DIR="${HOME}/repos/dotfiles"
HOMEBREW_DIR="/opt/homebrew"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Auto-deduplicate PATH entries
typeset -U PATH path

# History
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=2000000
export HISTORY_IGNORE="(ls|ll|cd|cd ~|clear|exit)"
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Globbing
setopt EXTENDED_GLOB

# GPG signing
export GPG_TTY="$(tty)"

# Load custom zsh completions
if [ -d "${DOTFILES_DIR}/zsh-completion" ]; then
    fpath=("${DOTFILES_DIR}/zsh-completion" $fpath)
fi

# Path to your Oh My Zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git                      # git aliases + prompt info (replaces bash-git-prompt)
    fzf                      # fzf key bindings + completions
    nvm                      # lazy-loads nvm (replaces manual NVM sourcing + bash_completion)
    z                        # jump to frecently-used directories
    zsh-autosuggestions      # fish-style inline suggestions (install separately)
    zsh-syntax-highlighting  # colors valid/invalid commands (install separately)
    you-should-use           # reminds you to use aliases (install separately)
    zsh-bat                  # wraps cat with bat (install separately)
)

. "${ZSH}/oh-my-zsh.sh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Include the user's bin dir in PATH
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

if [ -d "${HOME}/.local/bin" ]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ]; then
    export PATH="${DOTFILES_DIR}/bin:${PATH}"
fi

# Include brew's bin dir in PATH
if [ -d "${HOMEBREW_DIR}/bin" ]; then
    export PATH="${HOMEBREW_DIR}/bin:${PATH}"
fi

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Load aliases
if [ -f "${DOTFILES_DIR}/shell/mac/aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/mac/aliases.sh"
fi

# Load functions
if [ -f "${DOTFILES_DIR}/shell/mac/functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/mac/functions.sh"
fi

# .fzf command line fuzzy finder
# Note: run `fzf --zsh` to generate ~/.fzf.zsh (requires fzf >= 0.48)
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Java
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:${PATH}"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
fi

# Android development
if [ -d "${HOME}/Library/Android/sdk" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/emulator"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi

# Ruby
if command -v rbenv > /dev/null; then
    eval "$(rbenv init - zsh)"
fi

# Yarn global bin
if [ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]; then
    export PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
fi

# Tizen Studio
if [ -d "${HOME}/tizen-studio" ]; then
    export PATH="${PATH}:${HOME}/tizen-studio/tools/"
    export PATH="${PATH}:${HOME}/tizen-studio/tools/ide/bin"
fi

# Rust
[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"

# Docker Desktop
[ -f "${HOME}/.docker/init-zsh.sh" ] && . "${HOME}/.docker/init-zsh.sh"

unset DOTFILES_DIR HOMEBREW_DIR
