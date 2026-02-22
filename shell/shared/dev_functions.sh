# -*- shell-script -*-
# shellcheck shell=bash
# Shared development functions — sourced by both bash and zsh

__git_delete_dead_local_branches_not_on_remote()
{
    # Attempt to delete any dead local branches
    #
    # This seemed to work on 2019-02-28 and again on 2020-09-15
    # notes: https://stackoverflow.com/questions/13064613/how-to-prune-local-tracking-branches-that-do-not-exist-on-remote-anymore
    #
    # Whats left TODO:
    # - Function fails on any repos not "fully merged". So need to list any branches that fail to be deleted.

    echo "TODO: finish this function :-)"
    return 0

    git fetch -p && git branch -r | awk '{print $1}' | grep -E -v -f /dev/fd/0 <( git branch -vv | grep origin ) | awk '{print $1}' | xargs git branch -d
    return "$?"
}

repo()
{
    # Lets you have aliases for your repos so you can quickly cd into them.
    # The function relies on a .repo-aliases file in your home directory.
    # It has to be a shell function because you wouldn't be able to cd
    # otherwise.
    #
    # Usage: repo [-l] {REPO_NAME}
    #
    # Options:
    # -l, --list  List the aliases

    local USAGE INPUT REPO_PATH

    USAGE="Usage: repo [-h] [-l] {REPO_NAME}"
    INPUT="${1:-""}"

    if [ "$INPUT" = "-h" ] || [ "$INPUT" = "--help" ] || [ "$INPUT" = "help" ]; then
        cmsg "$USAGE"
        return 0
    fi

    if [ -z "$INPUT" ]; then
        cmsg "$USAGE" 1>&2
        return 1
    fi

    if [ "$INPUT" = "-l" ] || [ "$INPUT" = "--list" ]; then
        cmsg -d "Available repos"
        dotfiles repos --list-keys
        return 0
    fi

    REPO_PATH="$(dotfiles repos "${INPUT}")"

    if [ -z "$REPO_PATH" ]; then
        cmsg -r "Invalid alias '${INPUT}'" 1>&2
        return 1
    fi

    cd "${REPO_PATH}" || return 1

    return 0
}
