from argparse import Namespace
from typing import Dict, Union

from dotfiles.cli import Arguments, Command, arguments_to_dict
from dotfiles.errors import InvalidSubcommand
from dotfiles.installers import uninstall_composer, uninstall_php


class UninstallCommand(Command):
    """`dotfiles uninstall` command"""
    __subcommands: Dict[str, callable] = {
        'composer': uninstall_composer,
        'php': uninstall_php
    }
    name: str = 'uninstall'
    description: str = 'Uninstall a program'
    help: str = 'uninstall a program'

    def __init__(self, subcommand: str, arguments: Union[Arguments, dict] = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = (arguments
                                     if isinstance(arguments, Arguments)
                                     else (Arguments.from_dict(arguments)
                                           if isinstance(arguments, dict)
                                           else Arguments()))

    @classmethod
    def from_arguments(cls, namespace: Union[Arguments, Namespace]) -> 'UninstallCommand':
        command: 'UninstallCommand' = cls(
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
            raise InvalidSubcommand(self.name, self.subcommand)
