from dotfiles import osinfo as _osinfo
from dotfiles.cli import Command, Arguments
from dotfiles.errors import ValidationError


class OsinfoCommand(Command):
    """`dotfiles osinfo` command"""
    name: str = 'osinfo'
    command_name: str = 'osinfo'
    description: str = 'Display basic info about your os'
    help: str = 'display basic info about your os'

    def __init__(
        self,
        codename: bool = False,
        id: bool = False,
        like: bool = False,
        pretty: bool = False,
        simplified: bool = False,
        version: bool = False
    ):
        super().__init__()
        self.codename = codename
        self.id = id
        self.like = like
        self.pretty = pretty
        self.simplified = simplified
        self.version = version

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'OsinfoCommand':
        if arguments is None:
            arguments = Arguments()
        command: 'OsinfoCommand' = cls(
            codename=arguments.get('codename', False),
            id=arguments.get('id', False),
            like=arguments.get('like', False),
            pretty=arguments.get('pretty', False),
            simplified=arguments.get('simplified', False),
            version=arguments.get('version', False),
        )
        command.shell_completion = arguments.get('completion', False)
        return command

    def validate(self):
        keys = ('codename', 'id', 'like', 'pretty', 'simplified', 'version')
        given_options = [k for k in keys if getattr(self, k, False) is True]
        if len(given_options) > 1:
            raise ValidationError(self.name, "You're only allowed to choose a single option.")

    def _execute(self) -> None:
        if self.version:
            print(_osinfo.version())
        elif self.id:
            print(_osinfo.id())
        elif self.like:
            print(' '.join(_osinfo.id_like()))
        elif self.simplified:
            print(_osinfo.ostype())
        elif self.codename:
            print(_osinfo.codename())
        elif self.pretty:
            print(_osinfo.pretty_name())
        else:
            print(_osinfo.name())
