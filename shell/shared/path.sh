# -*- shell-script -*-
# shellcheck shell=bash
# Shared functions — sourced by both bash and zsh

append_path()
{
    local path
    path="${1:-""}"

    if [ -z "$path" ] || [ ! -d "$path" ]; then
        return 1
    fi

    # affix colons on either side of $PATH to simplify matching
    case ":${PATH}:" in
        *:"$path":*)
            ;;
        *)
            export PATH="${PATH}:${path}"
            ;;
    esac
}

prepend_path()
{
    local path
    path="${1:-""}"

    if [ -z "$path" ] || [ ! -d "$path" ]; then
        return 1
    fi

    # affix colons on either side of $PATH to simplify matching
    case ":${PATH}:" in
        *:"$path":*)
            ;;
        *)
            export PATH="${path}:${PATH}"
            ;;
    esac
}
