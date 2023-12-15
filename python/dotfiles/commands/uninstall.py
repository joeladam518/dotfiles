from typing import Dict, Type, Union

from dotfiles.cli import Arguments, arguments_to_dict, Command, FromArgsNamespace, parse_install_uninstall_arguments
from dotfiles.errors import InvalidSubcommand
from dotfiles.commands.composer import UninstallComposerCommand
from dotfiles.commands.php import UninstallPhpCommand

_subcommands: Dict[str, Type[Command]] = {
    UninstallComposerCommand.command_name: UninstallComposerCommand,
    UninstallPhpCommand.command_name: UninstallPhpCommand
}


class UninstallCommand(Command):
    """`dotfiles uninstall` command"""
    name: str = 'uninstall'
    command_name: str = 'uninstall'
    description: str = 'Uninstall a program'
    help: str = 'uninstall a program'

    def __init__(self, subcommand: str, arguments: Union[Arguments, dict] = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = parse_install_uninstall_arguments(arguments)

    @classmethod
    def from_arguments(cls, namespace: FromArgsNamespace = None) -> 'UninstallCommand':
        command: 'UninstallCommand' = cls(
            subcommand=getattr(namespace, 'subcommand', ''),
            arguments=arguments_to_dict(namespace)
        )
        command.shell_completion = getattr(namespace, 'completion', False)
        return command

    def get_sell_completion_string(self) -> str:
        return ' '.join(_subcommands.keys())

    def _execute(self) -> None:
        subcommand_class = _subcommands.get(self.subcommand, None)

        if subcommand_class:
            subcommand = subcommand_class.from_arguments(self.arguments)
            subcommand.execute()
        else:
            raise InvalidSubcommand(self.name, self.subcommand)
