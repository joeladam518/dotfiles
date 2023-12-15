from dotfiles import osinfo as _osinfo
from dotfiles.cli import Command, FromArgsNamespace
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
    def from_arguments(cls, namespace: FromArgsNamespace = None) -> 'OsinfoCommand':
        command: 'OsinfoCommand' = cls(
            codename=getattr(namespace, 'codename', False),
            id=getattr(namespace, 'id', False),
            like=getattr(namespace, 'like', False),
            pretty=getattr(namespace, 'pretty', False),
            simplified=getattr(namespace, 'simplified', False),
            version=getattr(namespace, 'version', False)
        )
        command.shell_completion = getattr(namespace, 'completion', False)
        return command

    def validate(self):
        chosen_options = []
        for key, value in self.get_command_arguments().items():
            if value:
                chosen_options.append(key)
        if len(chosen_options) > 1:
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
