import typing


# Example configuration:
# from functions import json_to_csv, other_function
# def find_pre_process_function(data_provider: str, table_name: str
#                               ) -> Union[None, FunctionType]:
#     if data_provider == "provider1" and table_name == "table1":
#         return json_to_csv
#     elif data_provider == "provider2":
#         return other_function

from typing import Union
from types import FunctionType

def find_pre_process_function(data_provider: str, table_name: str
                              ) -> Union[None, FunctionType]:
    return
