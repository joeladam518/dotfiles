from dotfiles.cli import Command, Subcommand
from dotfiles.errors import InvalidSubcommand
from dotfiles.installers import install_composer, install_php

_available_subcommands = {
    'composer': install_composer,
    'php': install_php
}

def install(command: Command) -> None:
    """Install command handler"""
    subcommand: Subcommand = Subcommand.from_command(command)

    if subcommand.name in _available_subcommands:
        _available_subcommands[subcommand.name](subcommand)
    elif subcommand.completion is True:
        print(*_available_subcommands.keys(), sep=' ')
    else:
        subcommand_name = subcommand.name or ''
        raise InvalidSubcommand(f'invalid subcommand "{subcommand_name}"')
