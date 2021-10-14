# Pre-Processing

The pre-processing stage of the data pipeline determines whether a raw file needs to be rewriten before it is ingested in the data platform. We can use this step to get the file into a state that can be easily ingested. Some examples of changes are:
 - Changing column names in a .csv to match the schema we want
 - Reforming a .json file into a form that can be ingested, by taking a complex object and simplifying it
 - Pulling only the relevant information from a .json file and creating a .csv to make ingestion easier
In this `pre_process` folder we keep the code that needs to be run at this stage.

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

As you find that your source data needs pre-processing, add your own files and functions to this `pre_process` folder, and make sure they are referred to by the `find_pre_process_function` function in the `root.py` file to be used.

When the function is triggered, its only argument is an object that contains the details of the file, with some utility functions to interact with the file. The object is an instantiated version of the `PreProcess` class, [the definition of which you can see here](https://github.com/ingenii-solutions/azure-data-platform-data-engineering/blob/main/ingenii_data_engineering/pre_process.py). This has utility functions to make it easier to read and write files to make them compatible with the environment, so all you need to provide is the file-specific code. For example, at time of writing there are only two file formats that the platform can ingest:
1. A `.csv` file, which can be easily created with the `write_json_to_csv` file
1. A `.json` file where each row is a JSON object corresponding to one line of data, which can be eaily created with the `write_json` file.

## Development

To develop your own pre-processing functions, we can use a file local to your development machine, and then create a `PreProcess` object in `development` mode. This PreProcess object needs to refer to the `dbt` folder also in this repository, so the below example is assumed to be a file at the root of this repository: 

```python
from my_file import my_function
from ingenii_databricks.pre_process import PreProcess

pre_process_obj = PreProcess("data_provider", "table", "path/to/file.json",
                             development_dbt_root="dbt")
my_function(pre_process_obj) # Did it do what I expected?
```

## Deployment

This code is deployed to the environment by creating a Python pacakge and uploading this to the platform data lake `utilities` container so it is available to the Databricks engineering cluster to be installed. A package must be available to the container regardless of whether there are any pre-processing functions.

The creation and uploading of the package will be handled by the CI/CD pipeline, but in case you need to do this manually the steps are as follows. From the context of the root of the repository, the package is created with the command
```bash
python pre_process/setup.py bdist_wheel
```
This will create a `pre_process-1.0.0-py3-none-any.whl` file in the top level `dist` folder. `build` and `pre_process.egg-info` folders are also created with files we won't need, and all 3 folder are ignored by the `.gitignore` file and should not be committed to the repository. Upload the generated `.whl` file using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az_storage_blob_upload) command 
```bash
az storage blob upload --account-name <data lake name> --account-key <data lake account key> -f dist/pre_process-1.0.0-py3-none-any.whl -c utilities -n pre_process/pre_process-1.0.0-py3-none-any.whl
```
In the above example we use the account key, but any authentication that the [Azure CLI command supports](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az_storage_blob_upload) can be used with an adjusted command.
