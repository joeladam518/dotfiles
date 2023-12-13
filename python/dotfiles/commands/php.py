import os
import re
import sys
from subprocess import CalledProcessError
from typing import Optional, Tuple, List

from dotfiles import array, console, osinfo, run, Version
from dotfiles.cli import Arguments, Command


class PhpVars:
    """Php variables for installation and uninstallation"""
    current_version: str = '8.3'
    versions: tuple = ('5.4', '5.5', '5.6', '7.0', '7.1', '7.2', '7.3', '7.4', '8.0', '8.1', '8.2', '8.3')
    extension_types: tuple = ('desktop', 'server')
    desktop_extensions: tuple = (
        'bcmath',
        'cli',
        'common',
        'curl',
        'intl',
        'mbstring',
        'opcache',
        'readline',
        'xml',
        'zip'
    )
    server_extensions: tuple = (
        'fpm',
        'gd',
        'igbinary',
        'memcached',
        'mysql',
        'pgsql',
        'redis',
        'sqlite3'
    )

    @classmethod
    def get_extensions(cls, extension_type: str, default_values: tuple = ()) -> tuple:
        """Get the extensions for the given extension type"""
        if extension_type == 'desktop':
            return cls.desktop_extensions

        if extension_type == 'server':
            return *cls.desktop_extensions, *cls.server_extensions

        return default_values


def _install_php_sources() -> None:
    """Install the php apt repository"""
    if osinfo.id() in ['debian', 'raspbian']:
        packages = ['apt-transport-https', 'ca-certificates', 'software-properties-common', 'lsb-release', 'gnupg2']
        run.command('apt install -y', *packages, root=True)
        run.command('wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg', root=True)
        source = 'deb https://packages.sury.org/php/ $(lsb_release -sc) main'
        source_file_path = '/etc/apt/sources.list.d/sury-php.list'
        run.command(f'echo "{source}" | sudo tee "{source_file_path}"')
    elif osinfo.id() == 'ubuntu':
        packages = ['software-properties-common', 'lsb-release']
        run.command('apt install -y', *packages, root=True)
        run.command('add-apt-repository ppa:ondrej/php -y', root=True)
    else:
        raise Exception('Unsupported OS')


def _php_sources_are_not_installed() -> bool:
    """Check see if the php apt repository is installed"""
    cmd = "find /etc/apt/ -name *.list | xargs cat | grep ^[[:space:]]*deb | grep '%s' | grep 'php'"
    if osinfo.id() in ['debian', 'raspbian']:
        if os.path.exists('/etc/apt/sources.list.d/sury-php.list'):
            return False
        proc = run.command(cmd % 'sury', check=False, supress_output=True)
        return proc.returncode == 0

    if osinfo.id() == 'ubuntu':
        if os.path.exists(f"/etc/apt/sources.list.d/ondrej-ubuntu-php-{osinfo.codename()}.list"):
            return False
        proc = run.command(cmd % 'ondrej', check=False, supress_output=True)
        return proc.returncode == 0

    return True


def _get_available_php_versions() -> tuple:
    """Find php versions by searching for packages with versions. i.e: 'php8.1-intl' """
    if _php_sources_are_not_installed():
        return PhpVars.versions

    try:
        cmd = "apt-cache search php | grep -oP '^php[0-9]?[0-9]\.[0-9]' | awk -F\php '{print $2}' | sort -u"
        versions = run.command(cmd, capture_output=True)
        versions = versions.split('\n') if versions else []
        return tuple(filter(bool, versions))
    except CalledProcessError:
        return PhpVars.versions


def _get_installed_php_packages(version: Optional[str] = None) -> list:
    """Get the currently installed php packages"""
    cmd = r"dpkg -l | grep -E '^[a-zA-Z]*\s*php%s' | sed 's/^[a-zA-Z]*\s*//' | sed 's/\s\{3,\}.*$//' | tr '\n' ' '"
    packages = run.command(cmd % (version or '*'), capture_output=True)
    packages = packages.strip().split(' ')
    return list(filter(bool, packages))


def _get_uninstallable_versions() -> Tuple[str]:
    """Filter the php versions to the one that can be uninstalled"""
    versions = map(lambda package: re.search(r'php(\d\.\d)?.*', package).group(1), _get_installed_php_packages())
    return array.unique(tuple(filter(bool, list(versions))))


class InstallPhpCommand(Command):
    name: str = 'php'
    description: str = 'Install php'
    help: str = 'install php'

    def __init__(self, env: Optional[str] = None, version: Optional[str] = None):
        super().__init__()
        self.env: Optional[str] = env
        self.version: Optional[str] = version

    @classmethod
    def from_arguments(cls, namespace: Arguments = None) -> 'Command':
        return cls(
            env=namespace.get('env', None),
            version=namespace.get('version', None)
        )

    def _execute(self) -> None:
        """"Install php"""
        if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
            print('Your operating system is not supported', file=sys.stderr)
            sys.exit(console.FAILURE)

        try:
            installable_versions: List[str] = [v for v in _get_available_php_versions() if Version(v).gt('7.4')]

            if self.version is None or self.version not in installable_versions:
                self.version = console.choice(
                    "Which version would you like to install?",
                    installable_versions,
                    default=PhpVars.current_version
                )
                if not self.version:
                    console.error('Invalid php version')
                    sys.exit(console.FAILURE)

            if self.env is None or self.env not in PhpVars.extension_types:
                self.env = console.choice(
                    "What kind of environment is this for?",
                    PhpVars.extension_types,
                    default='desktop'
                )
                if not self.env:
                    print('Environment not supported', file=sys.stderr)
                    sys.exit(console.FAILURE)

            # combine the packages to be installed
            extensions = array.unique([*PhpVars.get_extensions(self.env)])
            # build the extension strings and add them to the packages list
            packages = [f"php{self.version}", *list(map(lambda ext: f"php{self.version}-{ext}", extensions))]

            print()
            print("Packages to be installed:")
            print(*packages, sep='\n')

            print()
            if console.confirm('Proceed?'):
                if _php_sources_are_not_installed():
                    _install_php_sources()

                run.command('apt update', root=True)
                run.command('apt install -y', *packages, root=True)
            else:
                print("Exiting...")

            print()
        except KeyboardInterrupt as ex:
            print()
            raise ex


class UninstallPhpCommand(Command):
    name: str = 'php'
    description: str = 'Uninstall php'
    help: str = 'uninstall php'

    def __init__(self, version: Optional[str] = None):
        super().__init__()
        self.version: Optional[str] = version

    @classmethod
    def from_arguments(cls, namespace: Arguments = None) -> 'Command':
        return cls(
            version=namespace.get('version', None)
        )

    def _execute(self) -> None:
        """Uninstall php"""
        if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
            print('Your operating system is not supported', file=sys.stderr)
            sys.exit(console.FAILURE)

        try:
            uninstallable_versions: Tuple[str] = _get_uninstallable_versions()

            if not uninstallable_versions:
                print()
                print("No php packages found")
                print()
                sys.exit(console.SUCCESS)

            if self.version is None or self.version not in uninstallable_versions:
                self.version = console.choice(
                    "Which version would you like to uninstall?",
                    uninstallable_versions,
                    default=0
                )
                if not self.version:
                    console.error('Invalid php version')
                    sys.exit(console.FAILURE)

            packages = _get_installed_php_packages(self.version)

            if len(packages) == 0:
                print()
                print(f"No packages found for php{self.version}")
                print(f"No packages found for php{self.version}")
                print()
                sys.exit(console.SUCCESS)

            print()
            print('Packages to be uninstalled:')
            print(*packages, sep='\n')

            print()
            if console.confirm('Proceed?'):
                run.command('apt purge -y', *packages, root=True)
                run.command('apt autoremove -y', root=True)
            else:
                print("Exiting...")

            print()
        except KeyboardInterrupt as ex:
            print()
            raise ex
