import csv
import os
import platform
import sys
from argparse import ArgumentParser, Namespace
from typing import Optional

SUCCESS = 0
FAILURE = 1

# Functions
def __get_release_path() -> Optional[str]:
    root = os.path.abspath(os.sep)
    path = os.path.join(root, 'etc', 'os-release')
    if os.path.exists(path):
        return path

    path = os.path.join(root, 'usr', 'lib', 'os-release')
    if os.path.exists(path):
        return path

    return None


def __more_than_one_option_chosen(script_args: Namespace) -> None:
    count = 0
    for value in script_args.__dict__.values():
        if value:
            count = count + 1
        if count > 1:
            return True

    return False


def __parse_script_args():
    parser = ArgumentParser(description='Display basic info about your os')

    parser.add_argument('-c', '--codename', action='store_true', default=False,
                        help='get the codename')
    parser.add_argument('-i', '--id', action='store_true', default=False,
                        help='get the distro')
    parser.add_argument('-l', '--like', action='store_true', default=False,
                        help='get the distro that the current distro is like (for Linux)')
    parser.add_argument('-p', '--pretty', action='store_true', default=False,
                        help='get the pretty name')
    parser.add_argument('-s', '--simplified', action='store_true', default=False,
                        help='get the simplified os type (windows|mac|linux)')
    parser.add_argument('-v', '--version', action='store_true', default=False,
                        help='get the os version')

    return parser.parse_args()


def codename() -> str:
    """Get the distrubution's version codename."""
    return get_release_value('VERSION_CODENAME')


def get_release() -> dict:
    """Get the freedesktop release info. Mainly for linux operating systems.

    https://www.freedesktop.org/software/systemd/man/os-release.html
    In python 3.10 they introduced the 'freedesktop_os_release' function so if
    we have it we use it. But for older versions I've included a polyfill.

    Returns:
        dict: The OS release details
    """
    if ostype() not in ['linux', 'freebsd']:
        return {}

    if hasattr(platform, 'freedesktop_os_release'):
        try:
            return platform.freedesktop_os_release()
        except OSError:
            pass

    path = __get_release_path()

    if not path:
        return {}

    try:
        with open(path) as f:
            reader = csv.reader(f, delimiter="=")
            return {key: value for key, value in reader}
    except FileNotFoundError:
        return {}


def get_release_value(key) -> str:
    """Get a value from what's returned from get_release().

    Returns:
        str: The release value
    """
    return get_release().get(key, '')


def id() -> str:
    """Get the operating system's identifier.

    If not a freedesktop system, this will just return the type of system.
    """
    system_type = ostype()

    if system_type in ['linux', 'freebsd']:
        # Returns the lowercase operating system name for linux/freebsd based systems
        # https://www.freedesktop.org/software/systemd/man/os-release.html#ID=
        return get_release_value('ID')

    return system_type


def id_like() -> tuple:
    """The operating systems that the the local operating system is based on.

    If not a freedesktop system, this will just return the type of system.
    """
    system_type = ostype()

    if system_type in ['linux', 'freebsd']:
        id_like = get_release_value('ID_LIKE')

        if not id_like:
            id_ = get_release_value('ID')
            return (id_,) if id_ else ()

        return tuple(id_like.split(' '))

    return system_type,


def name() -> str:
    """Get the name of the operating system."""
    system_type = ostype()

    if system_type == 'mac':
        return 'macOS'

    if system_type in ['linux', 'freebsd']:
        return get_release_value('NAME')

    return platform.system()


def ostype() -> str:
    """Get the type of operating system."""
    if sys.platform in ['win32', 'win64', 'cygwin']:
        return 'windows'

    system_type = platform.system().lower()

    if system_type == 'darwin':
        return 'mac'

    return system_type


def pretty_name() -> str:
    """Get the pretty name of the operating system."""
    system_type = ostype()

    if system_type in ['linux', 'freebsd']:
        return get_release_value('PRETTY_NAME')

    return f"{name()} {version()}"


def version() -> str:
    """Get the operating system version."""
    system_type = ostype()

    if system_type == 'windows':
        return platform.release()

    if system_type == 'mac':
        mac_ver = platform.mac_ver()
        return mac_ver[0]

    return get_release_value('VERSION_ID')


if __name__ == '__main__':
    args = __parse_script_args()

    if __more_than_one_option_chosen(args):
        print('You\'re only allowed to choose one of the options.', file=sys.stderr)
        sys.exit(FAILURE)

    if args.version:
        print(version())
    elif args.id:
        print(id())
    elif args.like:
        print(' '.join(id_like()))
    elif args.simplified:
        print(ostype())
    elif args.codename:
        print(codename())
    elif args.pretty:
        print(pretty_name())
    else:
        print(name())

    sys.exit(SUCCESS)
