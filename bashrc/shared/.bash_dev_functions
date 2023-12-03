# -*- shell-script -*-
# shellcheck shell=bash
# Shared development functions

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
    # It has to be a bash function because you wouldn't be able to cd
    # otherwise.
    #
    # Usage: repo [-l] {REPO_NAME}
    #
    # Options:
    # -l, --list  List the aliases

    local REPO_ALIAS REPO_PATH

    REPO_ALIAS="${1:-""}"
    if [ -z "${REPO_ALIAS}" ]; then
        cmsg -r "Invalid alias ''" 1>&2
        return 1
    fi

    if [ "$REPO_ALIAS" == "-l" ] || [ "$REPO_ALIAS" == "--list" ]; then
        cmsg -d "Available repos"
        dotfiles repos --list-keys
        return 0
    fi

    REPO_PATH="$(dotfiles repos "${REPO_ALIAS}")"

    if [ -z "$REPO_PATH" ]; then
        cmsg -r "Invalid alias '${REPO_ALIAS}'" 1>&2
        return 1
    fi

    cd "${REPO_PATH}" || return 1

    return 0
}
