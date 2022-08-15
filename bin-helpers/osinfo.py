import csv
import os
import platform
import sys
from typing import Optional

# Constants
SUCCESS = 0
FAILURE = 1

def get_os_release() -> dict:
    """
    Get the freedesktop release info. Mainly for linux operating systems.
    https://www.freedesktop.org/software/systemd/man/os-release.html
    In python 3.10 they introduced the 'freedesktop_os_release' function so if
    we have it we use it. But for older versions I've included a polyfill.
    :return: A dict of release information
    :rtype: dict
    """
    if os_type() not in ['linux', 'freebsd']:
        return {}

    if hasattr(platform, 'freedesktop_os_release'):
        try:
            return platform.freedesktop_os_release()
        except OSError:
            pass

    path = get_os_release_path()

    if not path:
        return {}

    with open(path) as f:
        reader = csv.reader(f, delimiter="=")
        return {key: value for key, value in reader}


def get_os_release_path() -> Optional[str]:
    root = os.path.abspath(os.sep)
    path = os.path.join(root, 'etc', 'os-release')
    if os.path.exists(path):
        return path

    path = os.path.join(root, 'usr', 'lib', 'os-release')
    if os.path.exists(path):
        return path

    return None


def get_os_release_value(key) -> str:
    return get_os_release().get(key, '')


def os_codename() -> str:
    return get_os_release_value('VERSION_CODENAME')


def os_id() -> str:
    """
    Get the operating system's identifier. If not a freedesktop
    system, this will just return the type of system.
    """
    system_type = os_type()

    if system_type in ['linux', 'freebsd']:
        # Returns the lowercase operating system name for linux/freebsd based systems
        # https://www.freedesktop.org/software/systemd/man/os-release.html#ID=
        return get_os_release_value('ID')

    return system_type


def os_id_like() -> tuple:
    """
    The operating systems that the the local operating system is based on. If not a
    freedesktop system, this will just return the type of system.
    """
    system_type = os_type()

    if system_type in ['linux', 'freebsd']:
        id_like = get_os_release_value('ID_LIKE')

        if not id_like:
            id_ = get_os_release_value('ID')
            return (id_,) if id_ else ()

        return tuple(id_like.split(' '))

    return system_type,


def os_name() -> str:
    system_type = os_type()

    if system_type == 'mac':
        return 'macOS'

    if system_type in ['linux', 'freebsd']:
        return get_os_release_value('NAME')

    return platform.system()


def os_pretty_name() -> str:
    system_type = os_type()

    if system_type in ['linux', 'freebsd']:
        return get_os_release_value('PRETTY_NAME')

    return f"{os_name()} {os_version()}"


def os_type() -> str:
    """Get the type of operating system"""
    if sys.platform in ['win32', 'win64', 'cygwin']:
        return 'windows'

    system_type = platform.system().lower()

    if system_type == 'darwin':
        return 'mac'

    return system_type


def os_version() -> str:
    """Get the operating system version"""
    system_type = os_type()

    if system_type == 'windows':
        return platform.release()

    if system_type == 'mac':
        mac_ver = platform.mac_ver()
        return mac_ver[0]

    return get_os_release_value('VERSION_ID')
