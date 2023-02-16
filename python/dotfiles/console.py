from . import arr
from typing import Any, Dict, List, Tuple, Union

SUCCESS = 0
FAILURE = 1
CTRL_C = 130


class EmptyAnswerError(ValueError):
    pass


class InvalidAnswerError(ValueError):
    pass


def confirm(question: str, tries: int = 2) -> bool:
    valid = {"yes": True, "ye": True, "y": True, "no": False, "n": False}

    while tries > 0:
        print(f"{question} (yes/no) [no]:")
        answer = input("> ").strip().lower()
        if answer in valid:
            return valid[answer]
        print(f'\nValue "{answer}" is invalid!')
        print(f'Options: "' + '", "'.join(valid.keys()) + '"\n')
        tries = tries - 1

    return False


def choice(
    question: str,
    choices: Union[Dict[str, Any], Tuple[Any, ...], List[Any]],
    default=None,
    attempts: int = 2,
    multiple: bool = False
) -> Union[Any, Tuple[Any, ...], None]:
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
            answer = arr.unique(tuple([a.strip() for a in answer.split(',') if a]))

        if not choices_is_dict:
            try:
                # convert the answer to ints because they arr the indexes of the array
                answer = tuple([int(a) for a in answer]) if multiple else int(answer)
            except ValueError:
                # passing here because the validate step will catch it
                pass

        # validate
        for a in arr.wrap(answer, tuple):
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
        except EmptyAnswerError:
            if default_is_valid_choice:
                return default

            raise InvalidAnswerError(f'Value "" is invalid!')

    while attempts > 0:
        try:
            answer = ask()
            return tuple([choices[a] for a in answer]) if multiple else choices[answer]
        except InvalidAnswerError as e:
            print(f"\n{e}\n")

        attempts = attempts - 1

    return None
