# Pre-Processing

The pre-processing stage of the data pipeline determines whether a file needs to be rewriten before it is ingested in the data platform. In this folder we keep the code that needs to be run at this stage.

## How the data pipeline uses this code

The steps the pipeline takes are:
1. When the cluster is starting, it installs your `pre-processing` package generated from your version of this repositry.
1. Import the `find_pre_process_function` dictionary from the `root.py` file
1. The name of the data provider and table is passed as the two arguments of this function.
1. If a value is returned, this needs to be a function. Details of the requirements of this function is in the section below.

## Example files

Example root.py file:
```python
from functions import json_to_csv, other_function
def find_pre_process_function(data_provider: str, table_name: str
                              ) -> Union[None, FunctionType]:
    if data_provider == "provider1" and table_name == "table1":
        return json_to_csv
    elif data_provider == "provider2":
        return other_function
```

## Functions

When the function is triggered, its only argument is an object that contains the details of the file, with some utility functions to interact with the file. The object is an instantiated version of the `PreProcess` class, [the definition of which you can see here](https://github.com/ingenii-solutions/azure-data-platform-data-engineering/blob/main/ingenii_data_engineering/pre_process.py).

As you find that your source data needs pre-processing, add your own files and functions to this `pre_process` folder, and make sure they are referred to by the `find_pre_process_function` function in the `root.py` file to be used.

## Development

To develop your own pre-processing functions, we can use a file local to your development machine, and then create a `PreProcess` object in `development` mode. This PreProcess object needs to refer to the `dbt` folder also in this repository, so the below example is assumed to be a file at the root of this repository: 

```python
from my_file import my_function
from ingenii_databricks.pre_process import PreProcess

pre_process_obj = PreProcess("data_provider", "table", "path/to/file.json",
                             development_dbt_root="dbt")
my_function(pre_process_obj) # Did it do what I expected?
```
