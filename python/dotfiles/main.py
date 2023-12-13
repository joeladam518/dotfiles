import sys
from argparse import ArgumentParser
from collections import OrderedDict
from typing import Dict, Tuple, Type

from dotfiles import console
from dotfiles.commands import InstallCommand, OsinfoCommand, RepoCommand, UninstallCommand
from dotfiles.commands import InstallComposerCommand, InstallPhpCommand
from dotfiles.commands import UninstallComposerCommand, UninstallPhpCommand
from dotfiles.cli import Command, HelpFormatter
from dotfiles.errors import InvalidCommand, InvalidSubcommand, ValidationError
from dotfiles.paths import home_path

_commands: OrderedDict[str, Type[Command]] = OrderedDict({
    InstallCommand.name: InstallCommand,
    OsinfoCommand.name: OsinfoCommand,
    RepoCommand.name: RepoCommand,
    UninstallCommand.name: UninstallCommand
})


def _get_parsers() -> Tuple[ArgumentParser, Dict[str, ArgumentParser]]:
    """Parse command line arguments"""
    parser = ArgumentParser(
        prog='dotfiles',
        description='Helper commands',
        formatter_class=HelpFormatter,
    )
    parser.add_argument(
        '--completion',
        action='store_true',
        default=False,
        help='shell completion'
    )
    subparsers = parser.add_subparsers(
        title='commands',
        dest='command',
        required=False
    )

    # Command: `osinfo`
    info_parser = subparsers.add_parser(
        OsinfoCommand.name,
        description=OsinfoCommand.description,
        help=OsinfoCommand.help,
    )
    info_parser.add_argument(
        '-c',
        '--codename',
        action='store_true',
        default=False,
        help='get the codename'
    )
    info_parser.add_argument(
        '-i',
        '--id',
        action='store_true',
        default=False,
        help='get the distro'
    )
    info_parser.add_argument(
        '-l',
        '--like',
        action='store_true',
        default=False,
        help='get the distro that the current distro is like (for Linux)'
    )
    info_parser.add_argument(
        '-p',
        '--pretty',
        action='store_true',
        default=False,
        help='get the pretty name'
    )
    info_parser.add_argument(
        '-s',
        '--simplified',
        action='store_true',
        default=False,
        help='get the simplified os type (windows|mac|linux)'
    )
    info_parser.add_argument(
        '-v',
        '--version',
        action='store_true',
        default=False,
        help='get the os version'
    )

    # Command: `repos`
    repo_parser = subparsers.add_parser(
        RepoCommand.name,
        description=RepoCommand.description,
        help=RepoCommand.help,
    )
    repo_parser.add_argument(
        'key',
        nargs='?',
        type=str,
        action='store',
        default=None,
        help="get path by alias key"
    )
    repo_parser.add_argument(
        '--directory-path',
        type=str,
        action='store',
        default=home_path('repos'),
        help="the directory where your git repositories are located"
    )
    repo_parser.add_argument(
        '--file-path',
        type=str,
        action='store',
        default=home_path('.repo-aliases'),
        help="repo aliases file path"
    )
    repo_parser.add_argument(
        '--list-keys',
        action='store_true',
        default=False,
        help="list keys"
    )
    repo_parser.add_argument(
        '--list-paths',
        action='store_true',
        default=False,
        help="list paths"
    )
    repo_parser.add_argument(
        '--sep',
        type=str,
        action='store',
        default="\n",
        help="set the separator for listing keys and paths"
    )

    # Command: `dotfiles install`
    install_parser = subparsers.add_parser(
        InstallCommand.name,
        description=InstallCommand.description,
        help=InstallCommand.help,
        formatter_class=HelpFormatter
    )
    install_subparsers = install_parser.add_subparsers(
        title='commands',
        dest='subcommand',
        required=False
    )

    # Command: `dotfiles install composer`
    install_composer_parser = install_subparsers.add_parser(
        InstallComposerCommand.name,
        description=InstallComposerCommand.description,
        help=InstallComposerCommand.help
    )

    # Command: `dotfiles install php`
    install_php_parser = install_subparsers.add_parser(
        InstallPhpCommand.name,
        description=InstallPhpCommand.description,
        help=InstallPhpCommand.help
    )
    install_php_parser.add_argument(
        'version',
        nargs='?',
        type=str,
        action='store',
        default=None,
        help='the php version to install'
    )
    install_php_parser.add_argument(
        '-e',
        '--env',
        type=str,
        action='store',
        choices=('desktop', 'server'),
        default='desktop',
        help='the type of environment php will be installed on'
    )

    # Command: `dotfiles uninstall`
    uninstall_parser = subparsers.add_parser(
        UninstallCommand.name,
        description=UninstallCommand.description,
        help=UninstallCommand.help,
        formatter_class=HelpFormatter
    )
    uninstall_subparsers = uninstall_parser.add_subparsers(
        title='commands',
        dest='subcommand',
        required=False
    )

    # Command: `dotfiles uninstall composer`
    uninstall_composer_parser = uninstall_subparsers.add_parser(
        UninstallComposerCommand.name,
        description=UninstallComposerCommand.description,
        help=UninstallComposerCommand.help
    )

    # Command: `dotfiles uninstall php`
    uninstall_php_parser = uninstall_subparsers.add_parser(
        UninstallPhpCommand.name,
        description=UninstallPhpCommand.description,
        help=UninstallPhpCommand.help
    )
    uninstall_php_parser.add_argument(
        'version',
        nargs='?',
        type=str,
        action='store',
        default=None,
        help='the php version to uninstall'
    )

    subparsers = OrderedDict({
        InstallCommand.name: install_parser,
        InstallComposerCommand.name: install_composer_parser,
        InstallPhpCommand.name: install_php_parser,
        OsinfoCommand.name: info_parser,
        RepoCommand.name: repo_parser,
        UninstallCommand.name: uninstall_parser,
        UninstallComposerCommand.name: uninstall_composer_parser,
        UninstallPhpCommand.name: uninstall_php_parser
    })

    return parser, subparsers


def cli() -> None:
    """Command line interface entry point"""
    parser, subparsers = _get_parsers()

    try:
        arguments = parser.parse_args()
        command_class = _commands.get(arguments.command, None)

        if command_class:
            command = command_class.from_arguments(arguments)
            command.execute()
        elif arguments.completion:
            print(*_commands.keys(), sep=' ')
        else:
            parser.error('the following arguments are required: command')

        sys.exit(console.SUCCESS)
    except (InvalidCommand, InvalidSubcommand, ValidationError) as ex:
        if ex.command in subparsers:
            subparser = subparsers[ex.command]
            subparser.error(str(ex))
        else:
            parser.error(str(ex))
    except KeyboardInterrupt:
        sys.exit(console.CTRL_C)


if __name__ == '__main__':
    cli()
