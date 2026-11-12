# -*- shell-script -*-
# shellcheck shell=bash

# Sets a boolean flag in the .env file of the current directory.
# Only touches the key if its current value is true, false or empty.
#   $1 - the env key
#   $2 - the value to set (true|false)
_oda_set_env_flag()
{
    local current key value
    key="${1-}"
    value="${2-}"

    if ! printf '%s' "$key" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*$'; then
        cmsg -y "\"${key}\" is not a valid env name, ignoring" 1>&2
        return 0
    fi

    if ! grep -q "^${key}=" .env; then
        cmsg -y "\"${key}\" was not found in the .env file, ignoring" 1>&2
        return 0
    fi

    current="$(grep -m1 "^${key}=" .env)"
    current="$(printf '%s' "${current#*=}" | tr -d "\"'[:space:]" | tr '[:upper:]' '[:lower:]')"

    case "$current" in
        true | false | "")
            sed -i '' "s/^${key}=.*/${key}=${value}/" .env
            cmsg -g "Set ${key}=${value}" 1>&2
            ;;
        *)
            cmsg -y "\"${key}\" is not a boolean flag, ignoring" 1>&2
            ;;
    esac

    return 0
}

# Helps you swap the env and build for development
# If no arguments are provided this is what happens
#   - swaps the env and the default instance will be satellite
#   - runs the dev:[theme] command
# --enable/--disable are applied to the .env last, so they win over the defaults
oda()
{
    local build_theme cwd default_instance key repo_root run_dev swap_env theme usage
    local -a disable_flags enable_flags
    cwd="$(pwd -P)"
    usage="Usage: oda [-h] [-d] [-t] [-e] [--station] [--enable FLAG] [--disable FLAG] {theme}

Options:
    -h, --help      Show this help message and exit
    -d              Only run the dev command
    -e              Only swap the env file
    -t              Only build the theme
    --station       Make sure the default instance is station
    --enable FLAG   Set a boolean env flag to true (repeatable)
    --disable FLAG  Set a boolean env flag to false (repeatable)

Arguments:
    theme           The theme to build or run the dev command for"
    disable_flags=()
    enable_flags=()
    build_theme=0
    default_instance="satellite"
    repo_root="${HOME}/repos/cruisedirector-mobile"
    run_dev=1
    swap_env=1
    theme=""

    if [ ! -d "${repo_root}" ]; then
        cmsg -r "The ondeck-app repo does not exist" 1>&2
        return 1
    fi

    while :; do
        case "${1-}" in
            -h | --help | h | help)
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
            --enable | --disable)
                if [ -z "${2-}" ] || [ "${2#-}" != "$2" ]; then
                    cmsg -r "$1 requires an env flag name" 1>&2
                    echo "$usage" 1>&2
                    return 1
                fi
                if [ "$1" = "--enable" ]; then
                    enable_flags+=("$2")
                else
                    disable_flags+=("$2")
                fi
                shift
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

    if [ "$swap_env" = 1 ]; then
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

        # Always off locally. Set or append: a missing key isn't always false
        # (ENABLE_VERSION_UPDATE_SCREEN defaults to on in src/env.ts).
        if [ -n "$(tail -c1 .env)" ]; then
            echo >> .env
        fi
        for key in FCM_ENABLED ENABLE_ECS_EVENTS ENABLE_VERSION_UPDATE_SCREEN; do
            if grep -q "^${key}=" .env; then
                sed -i '' "s/^${key}=.*/${key}=false/" .env
            else
                echo "${key}=false" >> .env
            fi
        done

        cmsg -g "Swapped .env file for ${theme}" 1>&2
    fi

    if [ "${#enable_flags[@]}" -gt 0 ] || [ "${#disable_flags[@]}" -gt 0 ]; then
        if [ ! -f "./.env" ]; then
            cmsg -r "\".env\" does not exist" 1>&2
            return 1
        fi

        for key in "${enable_flags[@]}"; do
            _oda_set_env_flag "$key" "true"
        done
        for key in "${disable_flags[@]}"; do
            _oda_set_env_flag "$key" "false"
        done
    fi

    if [ "$build_theme" = 1 ]; then
        if ! yarn run "theme:${theme}"; then
            return 1
        fi
    elif [ "$run_dev" = 1 ]; then
        if ! yarn run "dev:${theme}"; then
            return 1
        fi
    fi

    cd "${cwd}" || return 1

    return 0
}
