# -*- coding: utf-8 -*-

from dotfiles import osinfo
from dotfiles.utils import installed, is_cmd_installed, is_pkg_installed
from dotfiles.version import Version


__all__ = [
    'osinfo',
    'installed',
    'is_cmd_installed',
    'is_pkg_installed',
    'Version'
]
