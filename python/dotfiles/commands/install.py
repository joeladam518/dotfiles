from argparse import Namespace
from typing import Dict, Type, Union

from dotfiles.cli import Command, Arguments, arguments_to_dict
from dotfiles.errors import InvalidSubcommand
from dotfiles.installers import install_composer, install_php


class InstallCommand(Command):
    """`dotfiles install` command"""
    __subcommands: Dict[str, callable] = {
        'composer': install_composer,
        'php': install_php
    }
    name: str = 'install'
    description: str = 'Install a program'
    help: str = 'install a program'

    def __init__(self, subcommand: str, arguments: Union[Arguments, dict] = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = (arguments
                                     if isinstance(arguments, Arguments)
                                     else (Arguments.from_dict(arguments)
                                           if isinstance(arguments, dict)
                                           else Arguments()))

    @classmethod
    def from_arguments(cls, namespace: Union[Arguments, Namespace]) -> 'InstallCommand':
        command: 'InstallCommand' = cls(
            subcommand=getattr(namespace, 'subcommand', ''),
            arguments=arguments_to_dict(namespace)
        )
        command.shell_completion = getattr(namespace, 'completion', False)
        return command

    def get_sell_completion_string(self) -> str:
        return ' '.join(self.__subcommands.keys())

    def _execute(self) -> None:
        if self.subcommand in self.__subcommands:
            self.__subcommands[self.subcommand](self.arguments)
        else:
            raise InvalidSubcommand('install', self.subcommand)
