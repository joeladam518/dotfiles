# -*- shell-script -*-
# shellcheck shell=bash
# Shared development functions — sourced by both bash and zsh

_git_is_squash_merged()
{
    # Succeeds when BRANCH's combined changes already exist as a single commit
    # in TARGET, i.e. BRANCH was squash-merged into TARGET.
    #
    # Builds a throwaway commit (never referenced, so git gc cleans it up)
    # holding BRANCH's whole diff from the merge base, then asks `git cherry`
    # whether TARGET has a commit with the same patch.
    #
    # Usage: _git_is_squash_merged BRANCH TARGET

    local merge_base squashed

    merge_base="$(git merge-base "$2" "$1" 2>/dev/null)" || return 1
    squashed="$(git commit-tree "$(git rev-parse "${1}^{tree}")" -p "$merge_base" -m _ 2>/dev/null)" || return 1

    case "$(git cherry "$2" "$squashed" 2>/dev/null)" in
        "- "*) return 0 ;;
        *) return 1 ;;
    esac
}

git_delete_merged_branches()
{
    # Delete local branches that have been merged into the default branch
    # (main or master).
    #
    # Fetches (with prune) from the remote first, then compares against the
    # remote's default branch (e.g. origin/main) so a stale local main doesn't
    # hide merged branches. Falls back to a local main/master when there is no
    # remote. Lists what it will delete and asks before deleting.
    #
    # Never deleted: the default branch, the current branch, and any protected
    # branch. Protected branches are the built-in list below plus every
    # `dotfiles.protectedBranch` git config value. Values are glob patterns,
    # and a plain name also covers branches under it (`release` protects
    # `release/1.2`). Set them per repo, or globally in ~/.gitconfig:
    #
    #   git config --add dotfiles.protectedBranch 'uat'
    #   git config --add dotfiles.protectedBranch 'release/*'
    #
    # Usage: git_delete_merged_branches [-h] [-n] [-y] [-r REMOTE]
    #
    # Options:
    # -n, --dry-run  Only list the branches that would be deleted
    # -y, --yes      Don't ask for confirmation
    # -r, --remote   Remote to compare against (default: origin)
    #
    # Squash merges (GitHub's "Squash and merge") are detected too: a branch
    # counts as merged when the default branch already contains a commit with
    # the same combined changes. Branches deleted on the remote that can't be
    # confirmed merged are listed but never deleted.

    local usage remote dry_run assume_yes default_ref default_name current branch track reply failed
    local pattern protected nl
    local -a branches labels gone protect_refs

    usage="Usage: git_delete_merged_branches [-h] [-n|--dry-run] [-y|--yes] [-r|--remote REMOTE]"
    remote="origin"
    dry_run="0"
    assume_yes="0"
    failed="0"

    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) cmsg "$usage"; return 0 ;;
            -n|--dry-run) dry_run="1" ;;
            -y|--yes) assume_yes="1" ;;
            -r|--remote)
                if [ -z "${2:-}" ]; then
                    cmsg -r "Missing value for $1" 1>&2
                    return 1
                fi
                remote="$2"
                shift
                ;;
            *) cmsg -r "Invalid option '$1'" 1>&2; cmsg "$usage" 1>&2; return 1 ;;
        esac
        shift
    done

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        cmsg -r "Not inside a git repository" 1>&2
        return 1
    fi

    # Refresh remote-tracking branches, dropping ones deleted on the remote
    if git remote get-url "$remote" >/dev/null 2>&1; then
        git fetch --prune --quiet "$remote" || cmsg -y "Warning: failed to fetch '${remote}', using what's already local" 1>&2
        default_ref="$(git symbolic-ref --quiet --short "refs/remotes/${remote}/HEAD" 2>/dev/null)"
    fi

    # No remote HEAD recorded (or no remote): look for main/master ourselves
    if [ -z "$default_ref" ]; then
        for branch in main master; do
            if git show-ref --verify --quiet "refs/remotes/${remote}/${branch}"; then
                default_ref="${remote}/${branch}"
                break
            elif git show-ref --verify --quiet "refs/heads/${branch}"; then
                default_ref="$branch"
                break
            fi
        done
    fi

    if [ -z "$default_ref" ]; then
        cmsg -r "Couldn't find a default branch (main or master)" 1>&2
        return 1
    fi

    default_name="${default_ref#"${remote}"/}"
    current="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"

    # Expand the protected patterns into the local branches they match. Git
    # does the glob matching, so this behaves the same in bash and zsh.
    for pattern in main master develop development dev staging stage qa uat production prod; do
        protect_refs+=("refs/heads/${pattern}")
    done
    while IFS= read -r pattern; do
        [ -n "$pattern" ] && protect_refs+=("refs/heads/${pattern#refs/heads/}")
    done < <(git config --get-all dotfiles.protectedBranch 2>/dev/null)

    nl=$'\n'
    protected="${nl}$(git for-each-ref --format='%(refname:short)' "${protect_refs[@]}")${nl}"

    while IFS=$'\t' read -r branch track; do
        case "$branch" in
            "$default_name"|"$current") continue ;;
        esac
        case "$protected" in
            *"${nl}${branch}${nl}"*) continue ;;
        esac

        if git merge-base --is-ancestor "$branch" "$default_ref" 2>/dev/null; then
            # Regular merge (or fast-forward): the branch tip is in the default branch
            branches+=("$branch")
            labels+=("$branch")
        elif _git_is_squash_merged "$branch" "$default_ref"; then
            branches+=("$branch")
            labels+=("${branch} (squash-merged)")
        elif [ "$track" = "[gone]" ]; then
            # Deleted on the remote but its changes can't be matched in the
            # default branch (e.g. it changed again after the squash merge).
            # Too risky to delete automatically, so just mention it.
            gone+=("$branch")
        fi
    done < <(git for-each-ref --format='%(refname:short)%09%(upstream:track)' refs/heads/)

    if [ "${#gone[@]}" -gt 0 ]; then
        cmsg -y "Deleted on ${remote} but not confirmed merged (left alone, delete with git branch -D):"
        for branch in "${gone[@]}"; do
            echo "  ${branch}"
        done
    fi

    if [ "${#branches[@]}" -eq 0 ]; then
        cmsg -g "No local branches merged into ${default_ref}"
        return 0
    fi

    cmsg -d "Branches merged into ${default_ref}:"
    for branch in "${labels[@]}"; do
        echo "  ${branch}"
    done

    if [ "$dry_run" = "1" ]; then
        return 0
    fi

    if [ "$assume_yes" != "1" ]; then
        printf "Delete %s branch(es)? [y/N] " "${#branches[@]}"
        read -r reply
        case "$reply" in
            [yY]|[yY][eE][sS]) ;;
            *) cmsg -y "Aborted"; return 0 ;;
        esac
    fi

    # -D because `git branch -d` only checks against HEAD/upstream, and we've
    # already verified each branch is merged into the default branch
    for branch in "${branches[@]}"; do
        if git branch -D "$branch" >/dev/null 2>&1; then
            cmsg -g "Deleted ${branch}"
        else
            cmsg -r "Failed to delete ${branch} (checked out in another worktree?)" 1>&2
            failed="1"
        fi
    done

    [ "$failed" = "0" ]
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
