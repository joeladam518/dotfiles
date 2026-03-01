#!/usr/bin/env bash

set -Eeo pipefail

[ -d "${HOME}/.zsh" ] || mkdir -p "${HOME}/.zsh"
[ -d "${HOME}/.zsh/cache" ] || mkdir -p "${HOME}/.zsh/cache"
[ -d "${HOME}/.zsh/completion" ] || mkdir -p "${HOME}/.zsh/completion"
[ -d "${HOME}/.zsh/plugins" ] || mkdir -p "${HOME}/.zsh/plugins"
