from abc import ABC, abstractmethod
from argparse import Namespace, RawDescriptionHelpFormatter, PARSER
from collections import OrderedDict
from typing import Union

def _convert_args_to_dict(namespace: Union[Namespace, dict, None]) -> dict:
    """Converts a Namespace object to a dict."""
    return namespace.__dict__ if isinstance(namespace, object) else (namespace or {})


def _get_arg_strings(attributes: dict) -> list:
    """Returns a list of strings representing the attributes of an object."""
    arg_strings = []
    star_args = {}
    for name, value in list(attributes.items()):
        if name.isidentifier():
            arg_strings.append(f"{name}={repr(value)}")
        else:
            star_args[name] = value
    if star_args:
        arg_strings.append(f"**{repr(star_args)}")
    return arg_strings


class HelpFormatter(RawDescriptionHelpFormatter):
    """Custom help formatter that removes the default `positional arguments` and `optional arguments` headers"""
    def _format_action(self, action):
        # noinspection PyProtectedMember
        parts = super(RawDescriptionHelpFormatter, self)._format_action(action)
        if action.nargs == PARSER:
            parts = "\n".join(parts.split("\n")[1:])
        return parts


class Command:
    """Represents a command's data."""

    def __init__(self, name: str, arguments: dict):
        self.name: str = name
        self.completion: bool = False
        self.arguments: Union[OrderedDict, dict] = arguments

    @classmethod
    def from_namespace(cls, namespace: Union[Namespace, dict, None]) -> 'Command':
        """Creates a Command object from a Namespace object."""
        data = _convert_args_to_dict(namespace)
        command: Union[str, None] = data.get('command')
        args: dict = {k: data[k] for k in data.keys() - {'command'}}
        return cls(command, OrderedDict(args.items()))

    def __contains__(self, key):
        return key in self.arguments

    def __eq__(self, other):
        if not isinstance(other, Command):
            raise TypeError('Invalid type comparison.')

        return self.name == other.name and self.arguments == other.arguments

    def __repr__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.arguments)
        return ('%s(\n  name=%s,\n  arguments={\n%s\n  }\n)' %
                (type_name, self.name, ',\n'.join(map(lambda s: f"    {s}", arg_strings))))

    def __str__(self):
        return self.name


class Subcommand(Command):
    """Represents a subcommand's data"""

    def __init__(self, command_name: str, name: str, arguments: dict):
        super().__init__(name, arguments)
        self.command_name: str = command_name

    @classmethod
    def from_namespace(cls, namespace: Union[Namespace, dict, None]) -> 'Subcommand':
        data = _convert_args_to_dict(namespace)
        command: Union[str, None] = data.get('command')
        subcommand: Union[str, None] = data.get('subcommand')
        args: dict = {k: data[k] for k in data.keys() - {'command', 'subcommand'}}
        return cls(command, subcommand, args)

    @classmethod
    def from_command(cls, command: Command) -> 'Subcommand':
        """Creates a Subcommand object from a Command object"""
        subcommand_name: Union[str, None] = command.arguments.get('subcommand')
        args: dict = {k: command.arguments[k] for k in command.arguments.keys() - {'command', 'subcommand'}}
        subcommand = cls(command.name, subcommand_name, args)
        subcommand.completion = command.completion
        return subcommand

    def __eq__(self, other):
        if not isinstance(other, Subcommand):
            raise TypeError('Invalid type comparison.')
        return (
            self.name == other.name and
            self.command_name == other.command_name and
            self.arguments == other.arguments
        )

    def __repr__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.arguments)
        return ('%s(\n  name=%s,\n  command=%s,\n  arguments={\n%s\n  }\n)' %
                (type_name, self.name, self.command_name, ',\n'.join(map(lambda s: f"    {s}", arg_strings))))


class Arguments(ABC):
    """Basic arguments obejct. Kinda like a namespace but with better typing"""

    @classmethod
    @abstractmethod
    def from_command(cls, command: Command) -> 'Arguments':
        """Creates an Arguments object from a Command object"""

    def validate(self) -> None:
        """Validate the arguments"""

    def __contains__(self, key):
        return key in self.__dict__

    def __eq__(self, other):
        if not isinstance(other, Arguments):
            return NotImplemented
        return vars(self) == vars(other)

    def __repr__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.__dict__)
        return '%s(\n%s\n)' % (type_name, ',\n'.join(map(lambda s: f"  {s}", arg_strings)))
