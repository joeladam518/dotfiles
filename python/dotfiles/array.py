from collections import OrderedDict
from typing import Union, Any

ArrType = Union[list, tuple]


def exclude(items: ArrType, exclude_: ArrType) -> ArrType:
    """Exclude items from a list or tuple"""
    original_type = type(items)
    return original_type([item for item in items if item not in exclude_])


def wrap(value: Any, _type: type = list) -> ArrType:
    """Wrap a value in a list or tuple if it isn't already"""
    if isinstance(value, tuple) or isinstance(value, list):
        return value

    return _type([value])


def unique(items: ArrType) -> ArrType:
    """Remove duplicates from a list or tuple"""
    original_type = type(items)
    return original_type(OrderedDict.fromkeys(items))
