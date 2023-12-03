import sys
from argparse import ArgumentParser

from dotfiles import console, commands
from dotfiles.cli import Command, HelpFormatter
from dotfiles.errors import InvalidCommand, InvalidSubcommand, ValidationError
from dotfiles.paths import home_path


def _get_parser() -> ArgumentParser:
    """Parse command line arguments"""
    parser = ArgumentParser(
        prog='dotfiles',
        description='Helper commands',
        formatter_class=HelpFormatter,
    )
    subparsers = parser.add_subparsers(
        title='commands',
        dest='command',
        required=False
    )

    # Command: `osinfo`
    info_parser = subparsers.add_parser(
        'osinfo',
        description='Display basic info about your os',
        help='display basic info about your os',
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
        'repos',
        description='Repo aliases',
        help='repo aliases',
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
        'install',
        description='Install helpers',
        help='install helpers',
        formatter_class=HelpFormatter
    )
    install_subparsers = install_parser.add_subparsers(
        title='commands',
        dest='subcommand',
        required=False
    )

    # Command: `dotfiles install composer`
    install_subparsers.add_parser(
        'composer',
        description='Install composer for php',
        help='install composer for php'
    )

    # Command: `dotfiles install php`
    install_php_parser = install_subparsers.add_parser(
        'php',
        description='Install PHP',
        help='install php'
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
        'uninstall',
        description='Uninstall helpers',
        help='uninstall helpers',
        formatter_class=HelpFormatter
    )
    uninstall_subparsers = uninstall_parser.add_subparsers(
        title='commands',
        dest='subcommand',
        required=False
    )

    # Command: `dotfiles uninstall composer`
    uninstall_subparsers.add_parser(
        'composer',
        description='Install composer for php',
        help='install composer for php'
    )

    # Command: `dotfiles uninstall php`
    uninstall_php_parser = uninstall_subparsers.add_parser(
        'php',
        description='Uninstall PHP',
        help='uninstall php'
    )
    uninstall_php_parser.add_argument(
        'version',
        nargs='?',
        type=str,
        action='store',
        default=None,
        help='the php version to uninstall'
    )

    return parser

def cli() -> None:
    """Command line interface entry point"""
    try:
        parser = _get_parser()
        arguments, extra_arguments = parser.parse_known_args()
        command: Command = Command.from_namespace(arguments)

        if '--completion' in extra_arguments:
            command.completion = True

        if command.name in commands.__all__:
            commands.__dict__[command.name](command)
        elif command.completion is True:
            print(*commands.__all__, sep=' ')
        else:
            parser.print_help()

        sys.exit(console.SUCCESS)
    except (InvalidCommand, InvalidSubcommand, ValidationError) as ex:
        parser.error(str(ex))
    except KeyboardInterrupt:
        sys.exit(console.CTRL_C)


if __name__ == '__main__':
    cli()
