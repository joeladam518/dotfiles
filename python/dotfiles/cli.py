from abc import ABC, abstractmethod
from argparse import Namespace, RawDescriptionHelpFormatter, PARSER
from typing import Union, Set, List, Tuple, Any


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
        for name, value in kwargs.items():
            setattr(self, name, value)

    @classmethod
    def from_dict(cls, dictionary: dict) -> 'Arguments':
        """Creates a new Arguments object from a dict"""
        return cls(**dictionary)

    @classmethod
    def from_namespace(cls, namespace: Namespace) -> 'Arguments':
        """Creates a new Arguments object from a Namespace object"""
        return cls(**vars(namespace))

    def get(self, key, default=None) -> Any:
        """Gets a value from the arguments object"""
        return getattr(self, key, default)

    def keys(self):
        """Returns the keys of the arguments object"""
        return self.to_dict().keys()

    def to_dict(self) -> dict:
        """Converts the Arguments object to a dict"""
        return vars(self)

    def clone(self, without: Union[List[str], Set[str], Tuple[str], None] = None) -> 'Arguments':
        """Clones the Arguments object"""
        if without:
            return self.from_dict({k: v for k, v in self.to_dict().items() if k not in without})

        return self.from_dict(self.to_dict())

    def __bool__(self):
        return bool(self.to_dict())

    def __contains__(self, key):
        return key in self.__dict__

    def __eq__(self, other):
        if not isinstance(other, Arguments):
            return NotImplemented
        return vars(self) == vars(other)

    def __getattr__(self, name) -> Any:
        raise AttributeError(f"'{type(self).__name__}' object has no attribute '{name}'")

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


class Command(ABC):
    """Represents a command."""

    def __init__(self):
        self.shell_completion: bool = False

    @classmethod
    @abstractmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'Command':
        """Creates a new command from a Command object"""

    def get_sell_completion_string(self) -> str:
        """Returns the shell completion string for the command"""
        return ''

    def validate(self) -> None:
        """Validate the command's arguments.
        Throws a ValidationError if the validation fails"""

    @abstractmethod
    def _execute(self) -> None:
        """The method that every command must implement. This is them main logic of the command."""

    def execute(self) -> None:
        """Executes the command."""
        self.validate()

        if self.shell_completion:
            print(self.get_sell_completion_string())
        else:
            self._execute()

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
