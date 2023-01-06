from collections import OrderedDict
from typing import Union

ArrType = Union[list, tuple]


def exclude(items: ArrType, exclude_: ArrType) -> ArrType:
    original_type = type(items)
    return original_type([item for item in items if item not in exclude_])


def wrap(value, _type: type = list) -> ArrType:
    if isinstance(value, tuple) or isinstance(value, list):
        return value

    return _type([value])


def unique(items: ArrType) -> ArrType:
    original_type = type(items)
    return original_type(OrderedDict.fromkeys(items))
