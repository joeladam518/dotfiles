import argparse
import sys
from argparse import ArgumentParser, Namespace, RawDescriptionHelpFormatter, PARSER

from dotfiles import console
from dotfiles.errors import ValidationError
from dotfiles.osinfo import add_parser as _add_osinfo_parser
from dotfiles.php import add_install_parser as _add_php_install_parser
from dotfiles.php import add_uninstall_parser as _add_php_uninstall_parser
from dotfiles.repos import _get_repo_aliases, add_parser as _add_repos_parser


class _HelpFormatter(RawDescriptionHelpFormatter):
    """Custom help formatter that removes the default positional arguments header"""

    def _format_action(self, action):
        # noinspection PyProtectedMember
        parts = super(RawDescriptionHelpFormatter, self)._format_action(action)
        if action.nargs == PARSER:
            parts = "\n".join(parts.split("\n")[1:])
        return parts


def _build_parser() -> ArgumentParser:
    """Build the argument parser"""
    parser = ArgumentParser(
        prog='dotfiles',
        description='Helper commands',
        formatter_class=_HelpFormatter,
    )
    parser.add_argument(
        '--completion',
        action='store_true',
        default=False,
        help=argparse.SUPPRESS,
    )
    subparsers = parser.add_subparsers(
        title='commands',
        dest='command',
    )

    # Command: `dotfiles osinfo`
    _add_osinfo_parser(subparsers)

    # Command: `dotfiles repos`
    _add_repos_parser(subparsers)

    # Command: `dotfiles install`
    install_parser = subparsers.add_parser(
        'install',
        description='Install something',
        help='install somthing',
        formatter_class=_HelpFormatter,
    )
    install_subparsers = install_parser.add_subparsers(
        title='commands',
        dest='subcommand',
    )

    # Command: `dotfiles install php`
    _add_php_install_parser(install_subparsers)

    # Command: `dotfiles uninstall`
    uninstall_parser = subparsers.add_parser(
        'uninstall',
        description='Uninstall something',
        help='uninstall somthing',
        formatter_class=_HelpFormatter,
    )
    uninstall_subparsers = uninstall_parser.add_subparsers(
        title='commands',
        dest='subcommand',
    )

    # Command: `dotfiles uninstall php`
    _add_php_uninstall_parser(uninstall_subparsers)

    return parser


def _handle_completion(args: Namespace) -> None:
    """Print shell completion tokens for the given command level"""
    command = getattr(args, 'command', None)

    if not command:
        print('install osinfo repos uninstall')
    elif command == 'install':
        print('php')
    elif command == 'uninstall':
        print('php')
    elif command == 'repos':
        aliases = _get_repo_aliases(
            args.repos_path,
            args.file_path,
        )
        print(*aliases.keys(), sep=' ')

    sys.exit(0)


def cli() -> None:
    """Command line interface entry point"""
    parser = _build_parser()
    args = parser.parse_args()

    if args.completion:
        _handle_completion(args)

    if not hasattr(args, 'handler') or args.handler is None:
        parser.print_help()
        sys.exit(1)

    try:
        args.handler(args)
    except ValidationError as ex:
        print(f"error: {ex}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(console.CTRL_C)


if __name__ == '__main__':
    cli()
