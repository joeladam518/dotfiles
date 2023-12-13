# -*- coding: utf-8 -*-
from .composer import InstallComposerCommand, UninstallComposerCommand
from .install import InstallCommand
from .osinfo import OsinfoCommand
from .php import InstallPhpCommand, UninstallPhpCommand
from .repos import RepoCommand
from .uninstall import UninstallCommand


__all__ = [
    'InstallCommand',
    'InstallComposerCommand',
    'InstallPhpCommand',
    'OsinfoCommand',
    'RepoCommand',
    'UninstallCommand',
    'UninstallComposerCommand',
    'UninstallPhpCommand'
]
