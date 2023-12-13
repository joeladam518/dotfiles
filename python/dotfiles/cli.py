from abc import ABC, abstractmethod
from argparse import Namespace, RawDescriptionHelpFormatter, PARSER
from collections import OrderedDict
from typing import Union


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


class Arguments:
    """Basic arguments object. Kinda like a namespace"""

    def __init__(self, **kwargs):
        self.__dict__ = OrderedDict(kwargs)

    @classmethod
    def from_dict(cls, dictionary: dict) -> 'Arguments':
        """Creates a new Arguments object from a dict"""
        return cls(**dictionary)

    def get(self, key, default=None):
        """Gets a value from the arguments object"""
        return self.__dict__.get(key, default)

    def __bool__(self):
        return bool(self.__dict__)

    def __contains__(self, key):
        return key in self.__dict__

    def __eq__(self, other):
        if not isinstance(other, Arguments):
            return NotImplemented
        return vars(self) == vars(other)

    def __repr__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.__dict__)
        args_string = ', '.join(arg_strings)
        return f"{type_name}({args_string})"

    def __str__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.__dict__)
        args_string = ',\n'.join(map(lambda s: f"  {s}", arg_strings))
        return f"{type_name}(\n{args_string}\n)"


FromArgsNamespace = Union[Arguments, Namespace, dict, None]


class Command(ABC):
    """Represents a command."""

    def __init__(self):
        self.shell_completion: bool = False

    @classmethod
    @abstractmethod
    def from_arguments(cls, namespace: FromArgsNamespace = None) -> 'Command':
        """Creates a new command from a Command object"""

    def get_command_arguments(self) -> dict:
        """Returns an Arguments object for the command"""
        return {k: self.__dict__[k] for k in self.__dict__.keys() - {'shell_completion'}}

    def get_sell_completion_string(self) -> str:
        """Returns the shell completion string for the command"""
        return ''

    def validate(self) -> None:
        """Validate the command's arguments.
        Throws a ValidationError if the validation fails"""

    @abstractmethod
    def _execute(self) -> None:
        """The method that every command must implement.
        This is them main logic of the command."""

    def execute(self) -> None:
        """Executes the command."""
        self.validate()

        if self.shell_completion:
            print(self.get_sell_completion_string())
        else:
            self._execute()

    def __bool__(self):
        return bool(self.get_command_arguments())

    def __contains__(self, key):
        return key in self.__dict__

    def __eq__(self, other):
        if not isinstance(other, Command):
            return NotImplemented
        return vars(self) == vars(other)

    def __repr__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.__dict__)
        args_string = ', '.join(arg_strings)
        return f"{type_name}({args_string})"

    def __str__(self):
        type_name = type(self).__name__
        arg_strings = _get_arg_strings(self.__dict__)
        args_string = ',\n'.join(map(lambda s: f"  {s}", arg_strings))
        return f"{type_name}(\n{args_string}\n)"


def arguments_to_dict(namespace: FromArgsNamespace) -> dict:
    """Converts an object to a dict."""
    arguments = namespace.__dict__ if isinstance(namespace, object) else (namespace or {})
    return {k: arguments[k] for k in arguments.keys() - {'command', 'subcommand', 'shell_completion'}}


def parse_install_uninstall_arguments(arguments: Union[Arguments, dict] = None) -> Arguments:
    """Parses the arguments for the install and uninstall commands"""
    if isinstance(arguments, Arguments):
        return arguments

    if isinstance(arguments, dict):
        return Arguments.from_dict(arguments)

    return Arguments()
