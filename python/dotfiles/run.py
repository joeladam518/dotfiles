import os
import subprocess
import sys
from . import osinfo
from typing import Union

# Types
CompletedProcess = subprocess.CompletedProcess
RunOutput = Union[CompletedProcess, str]


def command(cmd: str, *args, **kwargs) -> RunOutput:
    """
    Run a command
    :param str cmd: The command
    :param args: The command's arguments
    :param check: Raise CalledProcessError on failure
    :param supress_output: Don't print/return any output
    :param capture_output: Return output instead or printing it out
    :param env: dictionary of env vars to run with the script
    :param timeout: timeout after n number of seconds
    :return: The command's output
    :rtype: RunOutput
    """
    arguments = [cmd, *args]
    executable = None if osinfo.ostype() == 'windows' else os.environ.get('SHELL', '/bin/sh')
    supress_output = kwargs.get('supress_output', False)
    capture_output = False if supress_output else kwargs.get('capture_output', False)
    stdout = subprocess.DEVNULL if supress_output else None

    if kwargs.get('root', False):
        arguments.insert(0, 'sudo')

    process = subprocess.run(
        ' '.join(arguments),
        check=kwargs.get('check', True),
        shell=True,
        executable=executable,
        stdout=stdout,
        capture_output=capture_output,
        env=kwargs.get('env', None),
        timeout=kwargs.get('timeout')
    )

    if capture_output:
        output = process.stderr if process.returncode > 0 else process.stdout
        return output.decode(sys.getdefaultencoding())

    return process


def script(path: str, *args, **kwargs) -> RunOutput:
    """
    Run a script
    :param str path: The path to the script to run
    :param args: The command's arguments
    :param check: Raise CalledProcessError on failure
    :param supress_output: Don't print/return any output
    :param capture_output: Return output instead or printing it out
    :param env: dictionary of env vars to run with the script
    :param timeout: timeout after n number of seconds
    :return: The script's output
    :rtype: RunOutput
    """
    if not os.path.exists(path):
        raise FileNotFoundError(f"'{path}' was not found.")

    arguments = [path, *args]
    supress_output = kwargs.get('supress_output', False)
    capture_output = False if supress_output else kwargs.get('capture_output', False)
    stdout = subprocess.DEVNULL if supress_output else None

    if kwargs.get('root', False):
        arguments.insert(0, 'sudo')

    process = subprocess.run(
        arguments,
        check=kwargs.get('check', True),
        stdout=stdout,
        capture_output=capture_output,
        env=kwargs.get('env', None),
        timeout=kwargs.get('timeout')
    )

    if capture_output:
        output = process.stderr if process.returncode > 0 else process.stdout
        return output.decode(sys.getdefaultencoding())

    return process
