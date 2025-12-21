from typing import Dict, Type

from dotfiles.cli import Arguments, Command
from dotfiles.composer import UninstallComposerCommand
from dotfiles.errors import InvalidSubcommand
from dotfiles.php import UninstallPhpCommand

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

    def __init__(self, subcommand: str, arguments: Arguments = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = arguments or Arguments()

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'UninstallCommand':
        if arguments is None:
            arguments = Arguments()
        command: 'UninstallCommand' = cls(
            subcommand=arguments.get('subcommand', ''),
            arguments=arguments.clone(without={'command', 'subcommand', 'completion'})
        )
        command.shell_completion = arguments.get('completion', False)
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
