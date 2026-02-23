import shutil
from collections import OrderedDict
from typing import Union, Any
from dotfiles import run

ArrType = Union[list, tuple]


def exclude(items: ArrType, exclude_: ArrType) -> ArrType:
    """Exclude items from a list or tuple"""
    original_type = type(items)
    return original_type([item for item in items if item not in exclude_])


def wrap(value: Any, _type: type = list) -> ArrType:
    """Wrap a value in a list or tuple if it isn't already"""
    if isinstance(value, tuple) or isinstance(value, list):
        return value
    return _type([value])


def unique(items: ArrType) -> ArrType:
    """Remove duplicates from a list or tuple"""
    original_type = type(items)
    return original_type(OrderedDict.fromkeys(items))


def installed(program: str) -> bool:
    """Checks if a program is installed.
    NOTE: Works in most cases, but not in every case. Doesn't recognize jetbrains programs.
          It's also finicky, you need to know the exact name of the command or package.

    :param str program: The program name to check
    :return: Boolean indicating weather or not the program is installed
    :rtype: bool
    """
    return is_cmd_installed(program) or is_pkg_installed(program)


def is_cmd_installed(program: str) -> bool:
    """Checks to see if a command is installed"""
    return shutil.which(program) is not None


def is_pkg_installed(program: str) -> bool:
    """Checks to see if a package is installed via dpkg"""
    proc = run.command(f"dpkg -l | grep -E '^ii' | grep -iwq '{program}'", check=False)
    return proc.returncode == 0
