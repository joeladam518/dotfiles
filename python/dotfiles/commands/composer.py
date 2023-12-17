import hashlib
import os
import shutil
import sys
from subprocess import CalledProcessError
from urllib import request

from dotfiles import console, run, osinfo
from dotfiles.cli import Arguments, Command
from dotfiles.console import get_root_directory
from dotfiles.errors import ValidationError
from dotfiles.installed import installed
from dotfiles.paths import home_path


class InstallComposerCommand(Command):
    """`dotfiles install composer` command"""
    name: str = 'install_composer'
    command_name: str = 'composer'
    description: str = 'Install php-composer'
    help: str = 'install php-composer'

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'InstallComposerCommand':
        return cls()

    def validate(self) -> None:
        if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
            raise ValidationError(self.name, 'Your operating system is not supported')

        if not installed('php'):
            raise ValidationError(self.name, 'You must install php before you can install composer')

    def _execute(self) -> None:
        """Installs php-composer"""
        os.chdir(home_path())
        composer_setup_path = home_path('composer-setup.php')
        composer_path = home_path('composer.phar')

        with request.urlopen('https://composer.github.io/installer.sig') as response:
            expected_signature = response.read().decode('utf-8')

        with request.urlopen('https://getcomposer.org/installer') as response:
            with open(composer_setup_path, 'wb') as setup_file:
                shutil.copyfileobj(response, setup_file)

        with open(composer_setup_path, 'r', encoding='utf-8') as setup_file:
            actual_signature = hashlib.sha384(setup_file.read().encode())
            actual_signature = actual_signature.hexdigest()

        if actual_signature != expected_signature:
            print("Failed to install php-composer. Hashes didnt match", file=sys.stderr)
            sys.exit(console.FAILURE)

        try:
            run.command(f'php {composer_setup_path}')
            run.command(f'mv "{composer_path}" "/usr/local/bin/composer"', root=True)
            run.command(f'rm "{composer_setup_path}"')
        except CalledProcessError as ex:
            run.command(f'rm "{composer_setup_path}"')
            raise ex


class UninstallComposerCommand(Command):
    """`dotfiles uninstall composer` command"""
    name: str = 'uninstall_composer'
    command_name: str = 'composer'
    description: str = 'Uninstall php-composer'
    help: str = 'uninstall php-composer'

    @classmethod
    def from_arguments(cls, arguments: Arguments = None) -> 'UninstallComposerCommand':
        return cls()

    def validate(self) -> None:
        if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
            raise ValidationError(self.name, 'Your operating system is not supported')

        if os.path.exists(os.path.join(get_root_directory(), 'usr', 'local', 'bin', 'composer')):
            raise ValidationError(self.name, 'php-composer is not installed')

    def _execute(self) -> None:
        """Uninstalls php-composer"""
        run.command('rm "/usr/local/bin/composer"', root=True)
