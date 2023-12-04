import os
import sys
from argparse import Namespace
from collections import OrderedDict
from configparser import ConfigParser
from typing import Optional, Union

from dotfiles.cli import Command, Arguments
from dotfiles.errors import ValidationError
from dotfiles import console

SECTION_NAME = 'repos'


class RepoCommand(Command):
    """`dotfiles repos` command"""
    name: str = 'repos'
    description: str = 'Repo aliases'
    help: str = 'repo aliases'

    def __init__(
        self,
        key: str,
        repos_directory: str,
        aliases_file: str,
        list_keys: bool,
        list_paths: bool,
        sep: str
    ):
        super().__init__()
        self.key = key
        self.repos_directory = repos_directory
        self.aliases_file = aliases_file
        self.list_keys = list_keys
        self.list_paths = list_paths
        self.sep = sep

    @classmethod
    def from_arguments(cls, namespace: Union[Arguments, Namespace]) -> 'Command':
        command: 'RepoCommand' = cls(
            key=getattr(namespace, 'key', None),
            repos_directory=getattr(namespace, 'directory_path', None),
            aliases_file=getattr(namespace, 'file_path', None),
            list_keys=getattr(namespace, 'list_keys', False),
            list_paths=getattr(namespace, 'list_paths', False),
            sep=getattr(namespace, 'sep', "\n")
        )
        command.shell_completion = getattr(namespace, 'completion', False)
        return command

    def get_sell_completion_string(self) -> str:
        return ' '.join(self._get_repo_aliases().keys())

    def validate(self) -> None:
        if not self.aliases_file:
            raise ValidationError(self.name, 'Invalid repo aliases file path')
        if not self.repos_directory:
            raise ValidationError(self.name, 'Invalid repos directory path')
        if self.list_keys and self.list_paths:
            raise ValidationError(self.name, 'You can only one of "--list-keys" or "--list-paths" options')
        if not self.sep:
            raise ValidationError(self.name, 'Invalid sep')

    def _get_repo_aliases(self) -> dict:
        """Gets the repo aliases from the repo aliases file."""
        aliases_config = {}

        try:
            with open(self.aliases_file, 'r', encoding='utf-8') as file:
                config_parser = ConfigParser()
                config_parser.read_string(f'[{SECTION_NAME}]\n' + file.read())
                aliases_config = config_parser.items(SECTION_NAME)
        except FileNotFoundError:
            pass

        aliases = {key: os.path.expanduser(path) for (key, path) in aliases_config}
        aliases_paths = list(aliases.values())
        repos_directory_path = os.path.expanduser(self.repos_directory)

        if os.path.exists(repos_directory_path) and os.path.isdir(repos_directory_path):
            for f in os.scandir(repos_directory_path):
                if not f.is_dir():
                    continue

                path = os.path.abspath(f.path)

                if path not in aliases_paths:
                    aliases[f.name] = path

        return OrderedDict(sorted(aliases.items()))

    def _execute(self) -> None:
        repo_aliases = self._get_repo_aliases()

        if not repo_aliases:
            sys.exit(console.SUCCESS)

        if self.key is not None:
            if self.key not in repo_aliases:
                sys.exit(console.FAILURE)
            print(repo_aliases.get(self.key, ''))
        elif self.list_paths:
            print(*repo_aliases.values(), sep=self.sep.encode().decode('unicode-escape'))
        elif self.list_keys:
            print(*repo_aliases.keys(), sep=self.sep.encode().decode('unicode-escape'))
        else:
            length = max(len(x) for x in repo_aliases.keys())
            for key, path in repo_aliases.items():
                print(f'{key:{length}} {path}')
