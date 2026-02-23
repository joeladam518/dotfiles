import os
import sys
from argparse import ArgumentParser, Namespace, _SubParsersAction
from collections import OrderedDict
from configparser import ConfigParser

from dotfiles import console
from dotfiles.errors import ValidationError
from dotfiles.paths import home_path

SECTION_NAME = 'repos'


def _get_repo_aliases(repos_directory: str, aliases_file: str) -> dict:
    """Gets the repo aliases from the repo aliases file."""
    aliases_config = {}

    try:
        with open(aliases_file, 'r', encoding='utf-8') as file:
            config_parser = ConfigParser()
            config_parser.read_string(f'[{SECTION_NAME}]\n' + file.read())
            aliases_config = config_parser.items(SECTION_NAME)
    except FileNotFoundError:
        pass

    aliases = {key: os.path.expanduser(path) for (key, path) in aliases_config}
    aliases_paths = list(aliases.values())
    repos_directory_path = os.path.expanduser(repos_directory)

    if os.path.exists(repos_directory_path) and os.path.isdir(repos_directory_path):
        for f in os.scandir(repos_directory_path):
            if not f.is_dir():
                continue

            path = os.path.abspath(f.path)

            if path not in aliases_paths:
                aliases[f.name] = path

    return OrderedDict(sorted(aliases.items()))


def _configure_parser(p: ArgumentParser) -> None:
    """Add repos arguments to a parser or subparser"""
    p.add_argument(
        'key',
        nargs='?',
        type=str,
        default=None,
        help='get path by alias key'
    )
    p.add_argument(
        '--repos-path',
        type=str,
        default=home_path('repos'),
        help='the directory where your git repositories are located'
    )
    p.add_argument(
        '--file-path',
        type=str,
        default=home_path('.repo-aliases'),
        help='repo aliases file path'
    )
    p.add_argument(
        '--list-keys',
        action='store_true',
        default=False,
        help='list keys'
    )
    p.add_argument(
        '--list-paths',
        action='store_true',
        default=False,
        help='list paths'
    )
    p.add_argument(
        '--sep',
        type=str,
        default="\n",
        help='set the separator for listing keys and paths'
    )
    p.set_defaults(handler=cmd_repos)


def add_parser(subparsers: _SubParsersAction) -> ArgumentParser:
    """Register the repos subcommand with a parent subparsers group"""
    p = subparsers.add_parser(
        'repos',
        description='Repo aliases',
        help='repo aliases',
    )
    _configure_parser(p)
    return p


def cmd_repos(args: Namespace) -> None:
    """Handle the `dotfiles repos` command"""
    if not args.file_path:
        raise ValidationError('repos', 'Invalid repo aliases file path')
    if not args.repos_path:
        raise ValidationError('repos', 'Invalid repos directory path')
    if args.list_keys and args.list_paths:
        raise ValidationError('repos', 'You can only use one of "--list-keys" or "--list-paths" options')
    if not args.sep:
        raise ValidationError('repos', 'Invalid sep')

    repo_aliases = _get_repo_aliases(args.repos_path, args.file_path)

    if not repo_aliases:
        sys.exit(console.SUCCESS)

    if args.key is not None:
        if args.key not in repo_aliases:
            sys.exit(console.FAILURE)
        print(repo_aliases.get(args.key, ''))
    elif args.list_paths:
        print(*repo_aliases.values(), sep=args.sep.encode().decode('unicode-escape'))
    elif args.list_keys:
        print(*repo_aliases.keys(), sep=args.sep.encode().decode('unicode-escape'))
    else:
        length = max(len(x) for x in repo_aliases.keys())
        for key, path in repo_aliases.items():
            print(f'{key:{length}} {path}')
