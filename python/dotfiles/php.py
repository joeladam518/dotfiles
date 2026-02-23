import hashlib
import os
import re
import shutil
import sys
import tempfile
from argparse import ArgumentParser, Namespace, _SubParsersAction
from subprocess import CalledProcessError
from typing import Optional, Tuple, List
from urllib import request

from dotfiles import console, osinfo, run
from dotfiles.errors import ValidationError
from dotfiles.paths import home_path
from dotfiles.utils import array_unique, is_cmd_installed


_DESKTOP_EXTENSIONS: Tuple[str, ...] = (
    'bcmath',
    'cli',
    'common',
    'curl',
    'gd',
    'intl',
    'mbstring',
    'readline',
    'xml',
    'zip',
)

_SERVER_EXTENSIONS: Tuple[str, ...] = (
    'fpm',
    'igbinary',
    'mysql',
    'pgsql',
    'redis',
    'sqlite3',
)

_EXTENSION_TYPES: Tuple[str, ...] = ('desktop', 'server')

_DEFAULT_COMPOSER_DIR = '/usr/local/bin'


def _get_extensions(env: str) -> Tuple[str, ...]:
    """Get the php extensions for the given environment type"""
    if env == 'desktop':
        return _DESKTOP_EXTENSIONS
    if env == 'server':
        return array_unique((*_DESKTOP_EXTENSIONS, *_SERVER_EXTENSIONS))
    return ()


def _install_php_sources() -> None:
    """Install the php apt repository"""
    os_id = osinfo.id()

    if os_id == 'ubuntu':
        packages = ['apt-transport-https', 'ca-certificates', 'software-properties-common', 'lsb-release']
        run.command('apt install -y', *packages, root=True)
        run.command('add-apt-repository ppa:ondrej/php -y', root=True)
        return

    if os_id in ['debian', 'raspbian']:
        packages = ['apt-transport-https', 'ca-certificates', 'lsb-release', 'curl']
        run.command('apt install -y', *packages, root=True)
        keyring_url = 'https://packages.sury.org/debsuryorg-archive-keyring.deb'
        keyring_deb = '/tmp/debsuryorg-archive-keyring.deb'
        run.command(f'curl -sSLo {keyring_deb} {keyring_url}')
        run.command(f'dpkg -i {keyring_deb}', root=True)
        source = 'deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main'
        run.command(f'echo "{source}" | sudo tee /etc/apt/sources.list.d/php.list > /dev/null')
        return

    raise ValidationError('install_php', 'Unsupported OS for PHP repository setup')


def _php_sources_installed() -> bool:
    """Check if the php apt repository is installed"""
    os_id = osinfo.id()

    if os_id == 'ubuntu':
        codename = osinfo.codename()
        if os.path.exists(f"/etc/apt/sources.list.d/ondrej-ubuntu-php-{codename}.list"):
            return True
        if os.path.exists(f"/etc/apt/sources.list.d/ondrej-ubuntu-php-{codename}.sources"):
            return True
        cmd = r"find /etc/apt/ \( -name '*.list' -o -name '*.sources' \) -exec grep -l 'ondrej' {} \; 2>/dev/null | xargs grep -l 'php' 2>/dev/null"
        proc = run.command(cmd, check=False, supress_output=True)
        return proc.returncode == 0

    if os_id in ['debian', 'raspbian']:
        if os.path.exists('/etc/apt/sources.list.d/php.list'):
            return True
        if os.path.exists('/etc/apt/sources.list.d/sury-php.list'):
            return True
        cmd = r"find /etc/apt/ \( -name '*.list' -o -name '*.sources' \) -exec grep -l 'sury' {} \; 2>/dev/null | xargs grep -l 'php' 2>/dev/null"
        proc = run.command(cmd, check=False, supress_output=True)
        return proc.returncode == 0

    return False


def _get_available_php_versions() -> List[str]:
    """Get the available php versions from apt-cache"""
    try:
        cmd = r"apt-cache search php | grep -oP '^php[0-9]?[0-9]\.[0-9]' | awk -Fphp '{print $2}' | sort -ru"
        versions = run.command(cmd, capture_output=True)
        versions = versions.split('\n') if versions else []
        return list(filter(bool, versions))
    except CalledProcessError:
        return []


def _get_installed_php_packages(version: Optional[str] = None) -> List[str]:
    """Get the currently installed php packages"""
    cmd = r"dpkg -l | grep -E '^[a-zA-Z]*\s*php%s' | sed 's/^[a-zA-Z]*\s*//' | sed 's/\s\{3,\}.*$//' | tr '\n' ' '"
    packages = run.command(cmd % (version or '*'), capture_output=True)
    packages = packages.strip().split(' ')
    return list(filter(bool, packages))


def _get_uninstallable_versions() -> Tuple[str, ...]:
    """Get php versions that can be uninstalled"""
    versions = map(
        lambda package: re.search(r'php(\d\.\d)?.*', package).group(1),
        _get_installed_php_packages()
    )
    return array_unique(tuple(filter(bool, list(versions))))


def _find_composer_installations() -> List[str]:
    """Find existing composer installations"""
    candidates = [
        './composer',
        home_path('.local', 'bin', 'composer'),
        '/usr/local/bin/composer',
    ]
    which = shutil.which('composer')
    if which and which not in candidates:
        candidates.append(which)
    return [p for p in candidates if os.path.isfile(p)]


def _install_composer(install_dir: str) -> None:
    """Download and install composer to the given directory"""
    if not is_cmd_installed('php'):
        raise ValidationError('install_php', 'You must install php before you can install composer')

    with tempfile.TemporaryDirectory() as tmpdir:
        setup_path = os.path.join(tmpdir, 'composer-setup.php')

        with request.urlopen('https://composer.github.io/installer.sig') as response:
            expected_signature = response.read().decode('utf-8').strip()

        with request.urlopen('https://getcomposer.org/installer') as response:
            with open(setup_path, 'wb') as setup_file:
                setup_file.write(response.read())

        with open(setup_path, 'r', encoding='utf-8') as setup_file:
            actual_signature = hashlib.sha384(setup_file.read().encode()).hexdigest()

        if actual_signature != expected_signature:
            print("Failed to install composer. Hash verification failed.", file=sys.stderr)
            sys.exit(console.FAILURE)

        run.command(
            f'php {setup_path} --install-dir={install_dir} --filename=composer',
            root=True
        )


def _configure_install_parser(p: ArgumentParser) -> None:
    """Add install-php arguments to a parser or subparser"""
    p.add_argument(
        'version',
        nargs='?',
        type=str,
        default=None,
        help='the php version to install'
    )
    p.add_argument(
        '-e',
        '--env',
        type=str,
        choices=('desktop', 'server'),
        default=None,
        help='the type of environment php will be installed on'
    )
    p.add_argument(
        '--composer',
        nargs='?',
        const=_DEFAULT_COMPOSER_DIR,
        default=None,
        metavar='DIR',
        help='also install composer (optionally specify install directory, default: /usr/local/bin)'
    )
    p.set_defaults(handler=cmd_install_php)


def add_install_parser(subparsers: _SubParsersAction) -> ArgumentParser:
    """Register the `install php` subcommand with a parent subparsers group"""
    p = subparsers.add_parser(
        'php',
        description='Install php',
        help='install php',
    )
    _configure_install_parser(p)
    return p


def cmd_install_php(args: Namespace) -> None:
    """Install PHP (and optionally composer)"""
    if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
        raise ValidationError('install_php', 'Your operating system is not supported')

    try:
        if not _php_sources_installed():
            _install_php_sources()
            run.command('apt update', root=True)

        installable_versions = _get_available_php_versions()

        if not installable_versions:
            print()
            print("No php versions found", file=sys.stderr)
            print()
            sys.exit(console.FAILURE)

        version = args.version
        if version is None or version not in installable_versions:
            version = console.choice(
                "Which version would you like to install?",
                installable_versions,
                default=0
            )
            if not version:
                raise ValidationError('install_php', 'Invalid php version')

        env = args.env
        if env is None or env not in _EXTENSION_TYPES:
            env = console.choice(
                "What kind of environment is this for?",
                list(_EXTENSION_TYPES),
                default='desktop'
            )
            if not env:
                raise ValidationError('install_php', 'Invalid environment')

        extensions = _get_extensions(env)
        packages = [f"php{version}", *[f"php{version}-{ext}" for ext in extensions]]

        print()
        print("Packages to be installed:")
        print(*packages, sep='\n')

        print()
        if not console.confirm('Proceed?'):
            print("Exiting...")
            return

        run.command('apt update', root=True)
        run.command('apt install -y', *packages, root=True)

        # Composer step
        composer_dir = args.composer  # None, or a directory path
        existing = _find_composer_installations()

        if composer_dir is not None:
            target = os.path.join(composer_dir, 'composer')
            outside = [p for p in existing if os.path.abspath(p) != os.path.abspath(target)]
            if outside:
                print()
                print("Warning: existing composer installation(s) found outside the target directory:")
                for p in outside:
                    print(f"  {p}")
            print()
            print(f"Installing composer to {composer_dir}...")
            _install_composer(composer_dir)
        elif not existing:
            print()
            if console.confirm('Install composer?'):
                _install_composer(_DEFAULT_COMPOSER_DIR)
        else:
            print()
            print("Composer already installed:")
            for p in existing:
                print(f"  {p}")

    except KeyboardInterrupt:
        print()
        raise


def _configure_uninstall_parser(p: ArgumentParser) -> None:
    """Add uninstall-php arguments to a parser or subparser"""
    p.add_argument(
        'version',
        nargs='?',
        type=str,
        default=None,
        help='the php version to uninstall'
    )
    p.add_argument(
        '--composer',
        action='store_true',
        default=False,
        help='also uninstall composer'
    )
    p.set_defaults(handler=cmd_uninstall_php)


def add_uninstall_parser(subparsers: _SubParsersAction) -> ArgumentParser:
    """Register the `uninstall php` subcommand with a parent subparsers group"""
    p = subparsers.add_parser(
        'php',
        description='Uninstall php',
        help='uninstall php',
    )
    _configure_uninstall_parser(p)
    return p


def cmd_uninstall_php(args: Namespace) -> None:
    """Uninstall PHP (and optionally composer)"""
    if osinfo.id() not in ['debian', 'raspbian', 'ubuntu']:
        raise ValidationError('uninstall_php', 'Your operating system is not supported')

    try:
        uninstallable_versions = _get_uninstallable_versions()

        if not uninstallable_versions:
            print()
            print("No php packages found")
            print()
            sys.exit(console.SUCCESS)

        version = args.version
        if version is None or version not in uninstallable_versions:
            version = console.choice(
                "Which version would you like to uninstall?",
                list(uninstallable_versions),
                default=0
            )
            if not version:
                raise ValidationError('uninstall_php', 'Invalid php version')

        packages = _get_installed_php_packages(version)

        if not packages:
            print()
            print(f"No packages found for php{version}")
            print()
            sys.exit(console.SUCCESS)

        print()
        print('Packages to be uninstalled:')
        print(*packages, sep='\n')

        print()
        if not console.confirm('Proceed?'):
            print("Exiting...")
            return

        is_last_version = len(uninstallable_versions) == 1

        run.command('apt purge -y', *packages, root=True)
        run.command('apt autoremove -y', root=True)

        # Composer removal
        if args.composer:
            composer_path = os.path.join(_DEFAULT_COMPOSER_DIR, 'composer')
            if os.path.isfile(composer_path):
                run.command(f'rm "{composer_path}"', root=True)
            else:
                print("Composer not found, skipping...")
        elif is_last_version:
            existing = _find_composer_installations()
            if existing:
                print()
                if console.confirm('No PHP versions remain. Uninstall composer?'):
                    for p in existing:
                        run.command(f'rm "{p}"', root=True)

    except KeyboardInterrupt:
        print()
        raise
