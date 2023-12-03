import os
import sys
from configparser import ConfigParser
from typing import Optional
from collections import OrderedDict

from dotfiles.cli import Command, Arguments
from dotfiles.errors import ValidationError
from dotfiles import console

SECTION_NAME = 'repos'


def _get_repo_aliases(repos_path: str, repo_aliases_path: str) -> dict:
    """Gets the repo aliases from the repo aliases file."""
    repos_directory_path = os.path.expanduser(repos_path)

    if not os.path.exists(repos_directory_path):
        raise ValueError(f"'{repos_directory_path}' doesn't exist.")

    try:
        aliases_config = {}
        with open(repo_aliases_path, 'r', encoding='utf-8') as file:
            config_parser = ConfigParser()
            config_parser.read_string(f'[{SECTION_NAME}]\n' + file.read())
            aliases_config = config_parser.items(SECTION_NAME)
    except FileNotFoundError:
        pass

    aliases = {key: os.path.expanduser(path) for (key, path) in aliases_config}
    aliases_keys = list(aliases.keys())
    aliases_paths = list(aliases.values())

    def get_aliases_key(val) -> Optional[str]:
        try:
            pos = aliases_paths.index(val)
        except ValueError:
            return None

        return aliases_keys[pos]

    for f in os.scandir(repos_directory_path):
        if not f.is_dir():
            continue

        path = os.path.abspath(f.path)
        key = get_aliases_key(path)

        if key is None:
            aliases[f.name] = path

    return OrderedDict(sorted(aliases.items()))


class RepoArguments(Arguments):
    """Arguments for the `repo` command"""

    def __init__(
        self,
        key: str,
        repos_directory: str,
        aliases_file: str,

        list_keys: bool,
        list_paths: bool,
        sep: str
    ):
        self.key = key
        self.repos_directory = repos_directory
        self.aliases_file = aliases_file
        self.list_keys = list_keys
        self.list_paths = list_paths
        self.sep = sep

    @classmethod
    def from_command(cls, command: Command) -> 'RepoArguments':
        return cls(
            key=command.arguments.get('key', None),
            repos_directory=command.arguments.get('directory_path', None),
            aliases_file=command.arguments.get('file_path', None),
            list_keys=command.arguments.get('list_keys', False),
            list_paths=command.arguments.get('list_paths', False),
            sep=command.arguments.get('sep', "\n")
        )

    def validate(self) -> None:
        if not self.aliases_file:
            raise ValidationError('Invalid repo aliases file path')
        if not self.repos_directory:
            raise ValidationError('Invalid repos directory path')
        if self.list_keys and self.list_paths:
            raise ValidationError('You can only one of "--list-keys" or "--list-paths" options')
        if not self.sep:
            raise ValidationError('Invalid sep')


def repos(command: Command) -> None:
    """Repo aliases"""
    args = RepoArguments.from_command(command)
    args.validate()

    repo_aliases = _get_repo_aliases(args.repos_directory, args.aliases_file)

    if args.key is not None:
        if args.key not in repo_aliases:
            sys.exit(console.FAILURE)
        print(repo_aliases.get(args.key, ''))
    elif args.list_paths:
        print(*repo_aliases.values(), sep=args.sep.encode().decode('unicode-escape'))
    elif args.list_keys:
        print(*repo_aliases.keys(), sep=args.sep.encode().decode('unicode-escape'))
    elif command.completion is True:
        print(*repo_aliases.keys(), sep=' ')
    else:
        #length = max(len(x) for x in repo_aliases.keys())
        for key, path in repo_aliases.items():
            print(f'{key} = {path}')
