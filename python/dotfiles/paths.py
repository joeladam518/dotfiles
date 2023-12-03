import os
from getpass import getuser


def home_path(*paths: str) -> str:
    """Get the home directory path or a path within the home directory"""
    home_directory_path = os.path.expanduser(f"~{getuser()}")
    return os.path.join(home_directory_path, *paths) if len(paths) > 0 else home_directory_path
