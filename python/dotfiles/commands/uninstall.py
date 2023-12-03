from dotfiles.cli import Command, Subcommand
from dotfiles.errors import InvalidSubcommand
from dotfiles.installers import uninstall_composer, uninstall_php

available_subcommands = {
    'composer': uninstall_composer,
    'php': uninstall_php
}

def uninstall(command: Command) -> None:
    """Uninstall command handler."""
    subcommand: Subcommand = Subcommand.from_command(command)

    if subcommand.name in available_subcommands:
        available_subcommands[subcommand.name](subcommand)
    elif subcommand.completion is True:
        print(*available_subcommands.keys(), sep=' ')
    else:
        raise InvalidSubcommand(f'invalid subcommand "{subcommand.name}"')
