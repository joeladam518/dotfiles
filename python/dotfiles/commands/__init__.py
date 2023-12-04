# -*- coding: utf-8 -*-
from .install import InstallCommand
from .osinfo import OsinfoCommand
from .repos import RepoCommand
from .uninstall import UninstallCommand


__all__ = [
    'InstallCommand',
    'OsinfoCommand',
    'RepoCommand',
    'UninstallCommand'
]
