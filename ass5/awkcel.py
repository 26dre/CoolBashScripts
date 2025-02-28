# from collections import defaultdict


import sys
from typing import Callable, Dict, List


Position = int
VariableName = str
FLUSH_LEN = 1024


def parse_first_line(delimited_str: str, delimiter: str) -> Dict[str, Position]:
    return {key: pos for key, pos in enumerate(delimited_str.split(delimiter))}


def parse_file_line(csv_reader, predicate: Callable[[VariableName], bool], fields_requested: List[VariableName]):
    if fields_requested is None:
        return  # this is done to save any precious micro seconds in the competition against awk
