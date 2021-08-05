# Pre-processing

The pre-processing stage of the pipeline determines whether a file needs to
be pre-processed before it is ingested in the data platform. 

## Steps

The steps the pipeline taskes are are:
1. Import the 'pre_process_functions' dictionary from the `root.py` file
2. The first level of the dictionary are the names of the data providers
3. The second level are the names of the tables
4. The value is the function to apply if a match is found

Example configuration:
```python
from functions import json_to_csv

pre_process_functions = {
    "data_provider": {
        "table": json_to_csv
    }
}
```

## Functions

When the function is triggered, it is passed an object that contains the details of the file, with some utility functions to interact with the file. The object is an instantiated version of the `PreProcess` class, [the definition of which you can see here](https://github.com/ingenii-solutions/azure-data-platform-databricks-runtime/blob/feature/add_pre_processing/ingenii_databricks/pre_process.py).

As you find that your source data needs pre-processing, add your own files and functions to this `pre_process` folder, and make sure they are added to the `pre_process_functions` dictionary in the  the `root.py` file to be used.

## Development

To develop your own pre-processing functions, we can use a file local to your development machine, and then create a `PreProcess` object in `development` mode. An example is shown below: 

```python
from my_file import my_function
from ingenii_databricks.pre_process import PreProcess

pre_process_obj = PreProcess('data_provider', 'table', 'path/to/file.json',
                             development=True)
my_function(pre_process_obj) # Did it do what I expected?
```
