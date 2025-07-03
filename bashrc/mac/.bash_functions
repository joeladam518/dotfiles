# -*- shell-script -*-
# shellcheck shell=bash
# Mac Functions

# Import the global bash functions
if [ -f "${BASHRC_DIR}/shared/.bash_functions" ]; then
    . "${BASHRC_DIR}/shared/.bash_functions"
fi

# Import the shared dev functions
if [ -f "${BASHRC_DIR}/shared/.bash_dev_functions" ]; then
    . "${BASHRC_DIR}/shared/.bash_dev_functions"
fi

swap-env()
{
    local env
    env="$1"

    if [ -z "$env" ]; then
       cmsg -r "You must provide an env name" 1>&2
       return 1
    fi

    if [ ! -f "./.env-${env}" ]; then
       cmsg -r "\".env-${env}\" does not exist" 1>&2
       return 1
    fi

    ln -sf ".env-${env}" .env
    return "$?"
}

swap-theme()
{
    swap-env "$1"
    npm run "dev:$1"
}
