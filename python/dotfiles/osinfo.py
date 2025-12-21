import csv
import os
import platform
import sys
from typing import Optional

from dotfiles.cli import Command, Arguments
from dotfiles.errors import ValidationError


def __get_release_path() -> Optional[str]:
    """Get the path to the os-release file."""
    root = os.path.abspath(os.sep)
    path = os.path.join(root, 'etc', 'os-release')
    if os.path.exists(path):
        return path

    path = os.path.join(root, 'usr', 'lib', 'os-release')
    if os.path.exists(path):
        return path

    return None


def codename() -> str:
    """Get the distribution's version codename."""
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
        with open(path, encoding="utf-8") as f:
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
    """The operating systems that the local operating system is based on.

    If not a freedesktop system, this will just return the type of system.
    """
    system_type = ostype()

    if system_type in ['linux', 'freebsd']:
        id_like_ = get_release_value('ID_LIKE')

        if not id_like:
            id_ = get_release_value('ID')
            return (id_,) if id_ else ()

        return tuple(id_like_.split(' '))

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


class OsinfoCommand(Command):
    """`dotfiles osinfo` command"""
    name: str = 'osinfo'
    command_name: str = 'osinfo'
    description: str = 'Display basic info about your os'
    help: str = 'display basic info about your os'

    def __init__(
        self,
        codename: bool = False,
        id: bool = False,
        like: bool = False,
        pretty: bool = False,
        simplified: bool = False,
        version: bool = False
    ):
        super().__init__()
        self.codename = codename
        self.id = id
        self.like = like
        self.pretty = pretty
        self.simplified = simplified
        self.version = version

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'OsinfoCommand':
        if arguments is None:
            arguments = Arguments()
        command: 'OsinfoCommand' = cls(
            codename=arguments.get('codename', False),
            id=arguments.get('id', False),
            like=arguments.get('like', False),
            pretty=arguments.get('pretty', False),
            simplified=arguments.get('simplified', False),
            version=arguments.get('version', False),
        )
        command.shell_completion = arguments.get('completion', False)
        return command

    def validate(self) -> None:
        keys = ('codename', 'id', 'like', 'pretty', 'simplified', 'version')
        given_options = [k for k in keys if getattr(self, k, False) is True]
        if len(given_options) > 1:
            raise ValidationError(self.name, "You're only allowed to choose a single option.")

    def _execute(self) -> None:
        if self.version:
            print(version())
        elif self.id:
            print(id())
        elif self.like:
            print(' '.join(id_like()))
        elif self.simplified:
            print(ostype())
        elif self.codename:
            print(codename())
        elif self.pretty:
            print(pretty_name())
        else:
            print(name())
