from typing import Dict, Type


from dotfiles.cli import Arguments, Command
from dotfiles.composer import InstallComposerCommand
from dotfiles.errors import InvalidSubcommand
from dotfiles.php import InstallPhpCommand

_subcommands: Dict[str, Type[Command]] = {
    InstallComposerCommand.command_name: InstallComposerCommand,
    InstallPhpCommand.command_name: InstallPhpCommand
}


class InstallCommand(Command):
    """`dotfiles install` command"""
    name: str = 'install'
    command_name: str = 'install'
    description: str = 'Install a program'
    help: str = 'install a program'

    def __init__(self, subcommand: str, arguments: Arguments = None):
        super().__init__()
        self.subcommand: str = subcommand or ''
        self.arguments: Arguments = arguments or Arguments()

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'InstallCommand':
        if arguments is None:
            arguments = Arguments()
        command: 'InstallCommand' = cls(
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
