# Pre-Processing

The data we obtain from a data provider may not come the form we want; for every raw data file, after uploading it to the data lake but before ingesting into the data platform, the pre-processing stage can rewrite the file into a state that can be easily ingested. Some examples of changes are:
 - Changing column names in a .csv to match the schema we want
 - Reforming a .json file by taking a complex object and simplifying it
 - Pulling only the relevant information from a .json file and creating a .csv to make ingestion easier
In the `pre_process` folder of the repository we keep the code that needs to be run to pre-process the files, which is all in `python`. To handle a lot of boilerplate code, the `PreProcess` object is provided to make reading and writing your files easier, so all you have to provide is your data-specific code; this is detailed in the [Development](#development) section below.

- [Possible Data File Forms](#possible-data-file-forms) - The forms of data the platform can accept
- [How the data pipeline uses this code](#how-the-data-pipeline-uses-this-code) - How the code is executed against the raw file
- [Functions](#functions) - Your functions to rewrite the data
- [Development](#development) - Developing your functions locally, and using the `PreProcess` object
- [Deployment](#deployment) - Deploying your code to be available to the data platform

## Possible Data File Forms

Currently, there are two forms of data files that the platform will understand:

1. `.csv` or any 'separated' data type
    1. Each row of the file must correspond to one row of data
    1. If you have headers, then these must match the names of the column in the final tables
    1. If you do not have headers, then the schema [detailed in this documentation](understanding_and_ingesting_data.md) and the file must match including column order. If your columns can come in a different order or not all of the columns will be in each file, then you will need to have headers.
1. `.json`, where each row corresponds to one row of data, and each row is a JSON where the keys are the column names corresponding to each value.

```bash
# CSV Example

date,price1,price2,price3,price4
2011-03-01,12.4356,54.3156,8.6311,134.3651
2011-03-02,12.5645,54.3548,8.6531,132.4561
2011-03-03,13.1255,54.5688,8.6136,133.4171
2011-03-04,12.9865,54.4658,8.6121,134.8751
etc. . .


# JSON Example

{"date": "2011-03-01", "price1": 12.4356, "price2": 54.3156, "price3": 8.6311, "price4": 134.3651}
{"date": "2011-03-02", "price1": 12.5645, "price2": 54.3548, "price3": 8.6531, "price4": 132.4561}
{"date": "2011-03-03", "price1": 13.1255, "price2": 54.5688, "price3": 8.6136, "price4": 133.4171}
{"date": "2011-03-04", "price1": 12.9865, "price2": 54.4658, "price3": 8.6121, "price4": 134.8751}
etc. . . 

```

## How the data pipeline uses this code

In order to use your pre-processing code, the steps the pipeline takes are:
1. When the cluster is starting, it installs your `pre-processing` package generated from your version of this repositry.
1. Import the `find_pre_process_function` dictionary from the `root.py` file, which is at the root of the package
1. The name of the data provider and table is passed as the two arguments of this function.
1. If a value is returned, this needs to be a function which is run with the one argument of an initialised `PreProcess` object which does the file pre-processing. Full details of the requirements of this function is in the section below.

### Example files

The `root.py` file can be found at `pre_process/root.py`, and is used to determine which pre-processing function should be applied to a file, if any:
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

When the function is triggered, its only argument is an instantiated version of the `PreProcess` class, [the definition of which you can see here](https://github.com/ingenii-solutions/azure-data-platform-data-engineering/blob/main/ingenii_data_engineering/pre_process.py). This has utility functions to make it easier to read and write files to make them compatible with the environment, so all you need to provide is the file-specific code. For example, at time of writing there are only two file formats that the platform can ingest:
1. A `.csv` file, which can be easily created with the `write_json_to_csv` function
1. A `.json` file where each row is a JSON object corresponding to one line of data, which can be easily created with the `write_json` function

## Development

To develop your own pre-processing functions, we can use a file local to your development machine, and then create a `PreProcess` object in `development` mode; an example python script to do this is below. The `PreProcess` object needs access to the `dbt` folder also in this repository, so the below example is assumed to be a file at the root of this repository: 

```python
from pre_process.functions import my_function
from ingenii_data_engineering.pre_process import PreProcess

pre_process_obj = PreProcess("data_provider", "table", "path/to/file.json",
                             development_dbt_root="dbt")
my_function(pre_process_obj) # Did it do what I expected?
```

## Deployment

This code is deployed to the Data Platform by creating a Python pacakge and uploading this to the data lake `utilities` container; this makes it is available to the Data Platform Databricks engineering cluster to install. The cluster expects a package to be present, and so must be uploaded to the container regardless of whether there are any pre-processing functions or not.

The creation and uploading of the package will be handled by the CI/CD pipelines in the `CICD` folder - the files starting with `pre-processing` - but in case you need to do this manually the steps are as follows:

1. From the context of the root of the repository, the package is created with the command
```bash 
python -m ingenii_data_engineering pre_processing_package pre_process
```
2. This will create a `pre_process-1.0.0-py3-none-any.whl` file in the `dist` folder in the root of your repository. This folder will be created if it doesn't already exist. `build` and `pre_process.egg-info` folders are also created with files we won't need, and all 3 folder are ignored by the `.gitignore` file and should not be committed to the repository.

3. Upload the generated `.whl` file using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az_storage_blob_upload) command 
```bash
az storage blob upload --account-name <data lake name> --account-key <data lake account key> -f dist/pre_process-1.0.0-py3-none-any.whl -c utilities -n pre_process/pre_process-1.0.0-py3-none-any.whl
```
4. In the above example we use the account key, but any authentication that the [Azure CLI command supports](https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az_storage_blob_upload) can be used with an adjusted command.
