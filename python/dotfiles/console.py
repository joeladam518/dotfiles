import io
import os
import sys
from typing import Any, Dict, List, Tuple, Union, Literal, Iterable

from dotfiles import array
from dotfiles.errors import EmptyAnswerError, InvalidAnswerError

AttributeType = Literal[
    "bold",
    "dark",
    "italic",
    "underline",
    "blink",
    "reverse",
    "concealed",
]
ColorType = Literal[
    "black",
    "grey",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "light_grey",
    "dark_grey",
    "light_red",
    "light_green",
    "light_yellow",
    "light_blue",
    "light_magenta",
    "light_cyan",
    "white",
]

# Exit codes
SUCCESS = 0
FAILURE = 1
CTRL_C = 130

# ANSI escape codes
ATTRIBUTES: dict[AttributeType, int] = {
    "bold": 1,
    "dark": 2,
    "italic": 3,  # Not widely supported
    "underline": 4,
    "blink": 5,
    "reverse": 7,
    "concealed": 8,
}
COLORS: dict[ColorType, int] = {
    "black": 30,
    "grey": 30,  # Actually black but kept for backwards compatibility
    "red": 31,
    "green": 32,
    "yellow": 33,
    "blue": 34,
    "magenta": 35,
    "cyan": 36,
    "light_grey": 37,
    "dark_grey": 90,
    "light_red": 91,
    "light_green": 92,
    "light_yellow": 93,
    "light_blue": 94,
    "light_magenta": 95,
    "light_cyan": 96,
    "white": 97,
}
HIGHLIGHTS: dict[ColorType, int] = {
    "black": 40,
    "grey": 40,  # Actually black but kept for backwards compatibility
    "red": 41,
    "green": 42,
    "yellow": 43,
    "blue": 44,
    "magenta": 45,
    "cyan": 46,
    "light_grey": 47,
    "dark_grey": 100,
    "light_red": 101,
    "light_green": 102,
    "light_yellow": 103,
    "light_blue": 104,
    "light_magenta": 105,
    "light_cyan": 106,
    "white": 107,
}
RESET = "\033[0m"


def _can_do_colour(
    no_color: Union[bool, None] = None,
    force_color: Union[bool, None] = None
) -> bool:
    """Check env vars and for tty/dumb terminal"""
    # First check overrides:
    # "User-level configuration files and per-instance command-line arguments should
    # override $NO_COLOR. A user should be able to export $NO_COLOR in their shell
    # configuration file as a default, but configure a specific program in its
    # configuration file to specifically enable color."
    # https://no-color.org
    if no_color is not None and no_color:
        return False
    if force_color is not None and force_color:
        return True

    # Then check env vars:
    if "ANSI_COLORS_DISABLED" in os.environ:
        return False
    if "NO_COLOR" in os.environ:
        return False
    if "FORCE_COLOR" in os.environ:
        return True

    # Then check system:
    if os.environ.get("TERM") == "dumb":
        return False
    if not hasattr(sys.stdout, "fileno"):
        return False

    try:
        return os.isatty(sys.stdout.fileno())
    except io.UnsupportedOperation:
        return sys.stdout.isatty()


def colorize(
    text: object,
    color: Union[ColorType, None] = None,
    background: Union[ColorType, None] = None,
    attrs: Union[Iterable[AttributeType], None] = None,
    no_color: Union[bool, None] = None,
    force_color: Union[bool, None] = None,
) -> str:
    """Colorize text.

    Available colors:
        black, red, green, yellow, blue, magenta, cyan, white,
        light_grey, dark_grey, light_red, light_green, light_yellow, light_blue,
        light_magenta, light_cyan.

    Available attributes:
        bold, dark, underline, blink, reverse, concealed.

    Example:
        colorize('Hello, World!', 'red', 'on_black', ['bold', 'blink'])
        colorize('Hello, World!', 'green')
    """
    result = str(text)
    if not _can_do_colour(no_color, force_color):
        return result

    fmt_str = "\033[%dm%s"
    if color is not None:
        result = fmt_str % (COLORS[color], result)

    if background is not None:
        result = fmt_str % (HIGHLIGHTS[background], result)

    if attrs is not None:
        for attr in attrs:
            result = fmt_str % (ATTRIBUTES[attr], result)

    result += RESET

    return result


def cprint(
    text: object,
    color: Union[ColorType, None] = None,
    background: Union[ColorType, None] = None,
    attrs: Union[Iterable[AttributeType], None] = None,
    no_color: bool | None = None,
    force_color: bool | None = None,
    **kwargs: Any,
) -> None:
    """Print colorized text

    doc_inherit print
    """
    print(
        colorize(text, color, background, attrs, no_color, force_color),
        **kwargs
    )


def error(*args, **kwargs) -> None:
    """doc_inherit print"""
    kwargs['file'] = sys.stderr
    print(*args, **kwargs)


def confirm(question: str, tries: int = 2) -> bool:
    """Ask a yes/no question via input() and return their answer."""
    valid = {"yes": True, "ye": True, "y": True, "no": False, "n": False}

    while tries > 0:
        print(f"{question} (yes/no) [no]:")
        answer = input("> ").strip().lower()
        if answer in valid:
            return valid[answer]
        print(f'\nValue "{answer}" is invalid!')
        print('Options: "' + '", "'.join(valid.keys()) + '"\n')
        tries = tries - 1

    return False


def choice(
    question: str,
    choices: Union[Dict[str, Any], Tuple[Any, ...], List[Any]],
    default=None,
    attempts: int = 2,
    multiple: bool = False
) -> Union[Any, Tuple[Any, ...], None]:
    """Ask a choice question via input() and return their answer."""
    choices_is_dict = isinstance(choices, dict)
    if not choices_is_dict and default is not None and not isinstance(default, int):
        try:
            default = choices.index(default)
        except ValueError:
            default = None

    def is_choice(key: Union[str, int]) -> bool:
        if key is None:
            return False

        if choices_is_dict:
            key = str(key)
            return key in choices

        if not isinstance(key, int):
            return False

        return 0 <= key < len(choices)

    def get_answer() -> Union[Union[str, int], Tuple[Union[str, int], ...]]:
        answer = input("> ").strip()

        if answer == "" or answer is None:
            raise EmptyAnswerError()

        if multiple:
            answer = array.unique(tuple([a.strip() for a in answer.split(',') if a]))

        if not choices_is_dict:
            try:
                # convert the answer to ints because they arr the indexes of the array
                answer = tuple([int(a) for a in answer]) if multiple else int(answer)
            except ValueError:
                # passing here because the validate step will catch it
                pass

        # validate
        for a in array.wrap(answer, tuple):
            if not is_choice(a):
                raise InvalidAnswerError(f'Value "{a}" is invalid!')

        return answer

    def ask() -> Union[Union[str, int], Tuple[Union[str, int], ...]]:
        default_is_valid_choice = is_choice(default)

        # print question
        if default_is_valid_choice:
            default_display = default if choices_is_dict else choices[default]
            print(f"{question} [{default_display}]:")
        else:
            print(f"{question}:")

        # print choices
        items = choices.items() if choices_is_dict else enumerate(choices)
        for key, value in items:
            print(f" [{key}] {value}")

        try:
            return get_answer()
        except EmptyAnswerError as exc:
            if default_is_valid_choice:
                return default

            raise InvalidAnswerError('Value is invalid!') from exc

    while attempts > 0:
        try:
            answer = ask()
            return tuple([choices[a] for a in answer]) if multiple else choices[answer]
        except InvalidAnswerError as e:
            print(f"\n{e}\n")

        attempts = attempts - 1

    return None
