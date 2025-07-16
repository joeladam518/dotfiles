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

swapenv()
{
    local env
    env="$1"

    if [ -z "$env" ]; then
       cmsg -r "You must provide an env" 1>&2
       return 1
    fi

    if [ ! -f "./.env-${env}" ]; then
       cmsg -r "\".env-${env}\" does not exist" 1>&2
       return 1
    fi

    ln -sf ".env-${env}" .env
    
    return "$?"
}

swaptheme()
{
    local theme
    theme="$1"

    if [ -z "$theme" ]; then
       cmsg -r "You must provide a theme" 1>&2
       return 1
    fi

    if ! swapenv "$theme"; then
        return 1
    fi
    
    npm run "dev:$theme"

    return "$?"
}

