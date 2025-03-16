# from collections import defaultdict


import sys
from threading import Lock
from typing import Callable, Dict, List


Position = int
VariableName = str
FLUSH_LEN = 1024
unflushed_chars = 0
std_out_lock: Lock = Lock()


def flush_output():
    with std_out_lock:
        sys.stdout.flush()
        unflushed_chars = 0


def parse_first_line(delimited_str: str, delimiter: str) -> Dict[str, Position]:
    return {key: pos for key, pos in enumerate(delimited_str.split(delimiter))}


def parse_file_line(csv_reader, predicate: Callable[[VariableName], bool], fields_requested: List[VariableName]):
    if fields_requested is None:
        return  # this is done to save any precious micro seconds in the competition against awk


def s(pay, options, interest, years):

    total = options + pay*.5
    for i in range(years):
        total = total*interest + options + pay
