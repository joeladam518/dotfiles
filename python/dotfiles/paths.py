import os
from getpass import getuser


def get_os_root_directory() -> str:
    """Get the root directory of the current operating system"""
    return os.path.abspath(os.sep)


def home_path(*paths: str) -> str:
    """Get the home directory path or a path within the home directory"""
    home_directory_path = os.path.expanduser(f"~{getuser()}")
    return os.path.join(home_directory_path, *paths) if len(paths) > 0 else home_directory_path
