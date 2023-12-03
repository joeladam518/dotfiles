from dotfiles import osinfo as _osinfo
from dotfiles.cli import Arguments, Command
from dotfiles.errors import ValidationError


class OsinfoArguments(Arguments):
    """Arguments for the `osinfo` command"""

    def __init__(
        self,
        codename: bool = False,
        id: bool = False,
        like: bool = False,
        pretty: bool = False,
        simplified: bool = False,
        version: bool = False
    ):
        self.codename = codename
        self.id = id
        self.like = like
        self.pretty = pretty
        self.simplified = simplified
        self.version = version

    @classmethod
    def from_command(cls, command: Command) -> 'OsinfoArguments':
        return cls(
            codename=command.arguments.get('codename', False),
            id=command.arguments.get('id', False),
            like=command.arguments.get('like', False),
            pretty=command.arguments.get('pretty', False),
            simplified=command.arguments.get('simplified', False),
            version=command.arguments.get('version', False)
        )

    def validate(self):
        chosen_options = []
        for key, value in self.__dict__.items():
            if value:
                chosen_options.append(key)
        if len(chosen_options) > 1:
            raise ValidationError("You're only allowed to choose a single option.")


def osinfo(command: Command) -> None:
    """Display basic info about your os"""
    args = OsinfoArguments.from_command(command)
    args.validate()

    if args.version:
        print(_osinfo.version())
    elif args.id:
        print(_osinfo.id())
    elif args.like:
        print(' '.join(_osinfo.id_like()))
    elif args.simplified:
        print(_osinfo.ostype())
    elif args.codename:
        print(_osinfo.codename())
    elif args.pretty:
        print(_osinfo.pretty_name())
    else:
        print(_osinfo.name())
