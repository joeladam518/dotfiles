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

# Helps you swap the env and build for development
# If no arguments are provided this is what happens
#   - swaps the env and the default instance will be satellite
#   - runs the dev:[theme] command
oda()
{
    local build_theme cwd default_instance repo_root run_dev swap_env theme usage
    cwd="$(pwd -P)"
    usage="Usage: oda [-h] [-d] [-t] [-e] {theme}

Options:
    -h, --help  Show this help message and exit
    -d          Only run the dev command
    -e          Only swap the env file
    -t          Only build the theme
    --station   Make sure the default instance is station

Arguments:
    theme       The theme to build or run the dev command for"
    build_theme=0
    default_instance="satellite"
    repo_root="${HOME}/repos/ondeck-app"
    run_dev=1
    swap_env=1
    theme=""

    if [ ! -d "${repo_root}" ]; then
        cmsg -r "The ondeck-app repo does not exist" 1>&2
        return 1
    fi

    while :; do
        case "${1-}" in
            -h | --help)
                echo "$usage"
                return 0
                ;;
            -t)
                build_theme=1
                run_dev=0
                swap_env=0
                ;;
            -d)
                run_dev=1
                build_theme=0
                swap_env=0
                ;;
            -e)
                swap_env=1
                build_theme=0
                run_dev=0
                ;;
            --station)
                default_instance="station"
                ;;
            -?*)
                cmsg -r "Unknown option: $1" 1>&2
                return 1
                ;;
            ?*)
                if [ -n "$theme" ]; then
                    cmsg -r "You must only provide one theme" 1>&2
                    echo "$usage" 1>&2
                    return 1
                fi
                theme="$1"
                ;;
            *) break ;;
        esac
        shift
    done

    cd "${repo_root}" || return 1

    if [ -z "$theme" ]; then
       cmsg -r "Missing theme" 1>&2
       echo "$usage" 1>&2
       return 1
    fi

    if [ "$swap_env" == 1 ]; then
        if [ ! -f "./.github/public/${theme}/alpha.env" ]; then
            cmsg -r "\"./.github/public/${theme}/alpha.env\" does not exist" 1>&2
            return 1
        fi

        if [ -f "./.env" ] || [ -L "./.env" ]; then
            rm ./.env
        fi

        if ! cp "./.github/public/${theme}/alpha.env" .env; then
            return 1
        fi

        if [ ! -f "./.env" ]; then
            cmsg -r "\".env\" does not exist" 1>&2
            return 1
        fi

        sed -i '' 's/^SENTRY_DSN=.*/SENTRY_DSN=/' .env
        sed -i '' 's/^SENTRY_TRACING_ORIGINS=.*/SENTRY_TRACING_ORIGINS=/' .env
        sed -i '' "s/^DEFAULT_INSTANCE=.*/DEFAULT_INSTANCE=\"${default_instance}\"/" .env

        cmsg -g "Swapped .env file for ${theme}" 1>&2
    fi

    if [ "$build_theme" == 1 ]; then
        if ! yarn run "theme:${theme}"; then
            return 1
        fi
    elif [ "$run_dev" == 1 ]; then
        if ! yarn run "dev:${theme}"; then
            return 1
        fi
    fi

    cd "${cwd}" || return 1

    return 0
}
