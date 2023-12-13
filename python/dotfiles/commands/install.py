from typing import Dict, Union

from dotfiles.cli import Arguments, arguments_to_dict, Command, FromArgsNamespace, parse_install_uninstall_arguments
from dotfiles.errors import InvalidSubcommand
from dotfiles.commands.composer import InstallComposerCommand
from dotfiles.commands.php import InstallPhpCommand


class InstallCommand(Command):
    """`dotfiles install` command"""
    __subcommands: Dict[str, Command] = {
        'composer': InstallComposerCommand,
        'php': InstallPhpCommand
    }
    name: str = 'install'
    description: str = 'Install a program'
    help: str = 'install a program'

    def __init__(self, subcommand: str, arguments: Union[Arguments, dict] = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = parse_install_uninstall_arguments(arguments)

    @classmethod
    def from_arguments(cls, namespace: FromArgsNamespace = None) -> 'InstallCommand':
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
            subcommand = self.__subcommands[self.subcommand].from_arguments(self.arguments)
            subcommand.execute()
        else:
            raise InvalidSubcommand('install', self.subcommand)
