#!/usr/bin/env bash

## Variables
CWD=$(pwd)
BIN_DIR="$HOME/bin"
REPOS_DIR="$HOME/repos"
DOTFILES_DIR="$REPOS_DIR/dotfiles"

if [ ! -d "$REPOS_DIR" ]; then
    cd "$HOME" && mkdir "$REPOS_DIR"
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    cd "$REPOS_DIR" && git clone git@github.com:joeladam518/dotfiles.git
fi

if [ ! -d "$BIN_DIR" ]; then
    cd "$HOME" && mkdir "$BIN_DIR"
    PATH="$BIN_DIR:$PATH"
fi

# First install messages in color
if [ ! -f "$DOTFILES_DIR/bin/cmsg" ]; then
    echo "Could not find the cmsg program to install..."
    exit 1
fi

if [ ! -e "$BIN_DIR/cmsg" ]; then
    cd "$BIN_DIR" && ln -sf "$DOTFILES_DIR/bin/cmsg"
fi

# Install .bashrc files
if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.bashrc.old" ]; then
    cd "$HOME" && mv "$HOME/.bashrc" "$HOME/.bashrc.old"
    cd "$HOME" && ln -sf "$DOTFILES_DIR/bashrc/desktop/.bashrc"
    source "$HOME/.bashrc"
fi

# Install vim config files
if [ ! -L "$HOME/.vim" ] && [ ! -d "$HOME/.vim"]; then
    cd "$HOME" && ln -sf "$DOTFILES_DIR/vimrc/.vim"
fi

if [ ! -L "$HOME/.vimrc" ] && [ ! -f "$HOME/.vimrc"]; then
    cd "$HOME" && ln -sf "$DOTFILES_DIR/vimrc/.vimrc"
fi

# TODO: install the rest of the dotfiles

