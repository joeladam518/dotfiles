import hashlib
import os
import shutil
import sys
from subprocess import CalledProcessError
from urllib import request

from dotfiles import console, run
from dotfiles.installed import installed
from dotfiles.paths import home_path


def install_composer() -> None:
    """Installs php-composer"""
    if not installed('php'):
        print('You must install php before you can install composer', file=sys.stderr)
        sys.exit(console.FAILURE)

    os.chdir(home_path())
    composer_setup_path = home_path('composer-setup.php')
    composer_path = home_path('composer.phar')

    with request.urlopen('https://composer.github.io/installer.sig') as response:
        expected_signature = response.read().decode('utf-8')

    with request.urlopen('https://getcomposer.org/installer') as response:
        with open(composer_setup_path, 'wb') as setup_file:
            shutil.copyfileobj(response, setup_file)

    with open(composer_setup_path, 'r') as setup_file:
        actual_signature = hashlib.sha384(setup_file.read().encode())
        actual_signature = actual_signature.hexdigest()

    if actual_signature != expected_signature:
        print("Failed to install php-composer. Hashes didnt match", file=sys.stderr)
        sys.exit(console.FAILURE)

    try:
        run.command(f'php {composer_setup_path}')
        run.command(f'mv "{composer_path}" "/usr/local/bin/composer"', root=True)
    except CalledProcessError as ex:
        run.command(f'rm "{composer_setup_path}"')
        raise ex
    else:
        run.command(f'rm "{composer_setup_path}"')


def uninstall_composer() -> None:
    """Uninstalls php-composer"""
    run.command('rm "/usr/local/bin/composer"', root=True)
