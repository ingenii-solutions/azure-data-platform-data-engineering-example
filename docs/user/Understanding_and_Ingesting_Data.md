# Understanding and Ingesting Data

After uploading the raw data file into the data lake and, if required, pre-processing it into a form the platform can understand ([Pre-Processing](./Pre-Processing.md)), the final step covered here is to give the platform the metadata to understand how to read the file and create the corresponding tables in the platform itself. The dbt project in the `dbt` folder is where we set this metadata, giving information about the raw files and the data quality tests to apply. 

- [General configuration](#general-configuration) - Configuration relevant to all data
- [Data Integration](#data-integration) - What you need to integrate a new set of data files
- [dbt Resources:](#dbt-resources) - Further documentation about `dbt`

## General configuration

Separate to the individual table definitions described below, there is general configuration that applies to the whole platform. Below we detail what we've changed from the `dbt` default.

### `profiles.yml`

You shouldn't need to update this file, as the below is how it is set in the example files of this repository.

 - This file stays in the root of the project, rather than in a `/home/<username>/.dbt` folder. This is for simplification.
 - `host`, `token`, and `cluster` are drawn from environment variables that are set by our infrastructure deployment.
 - `threads` is set to 2, while the default is 5. We've found that when performing a lot of `dbt` tests the cluster seems to get overloaded and tests will randomly fail. You're free to increase this number, but be warned.
 - One configuration entry is the `retry_all` flag, which at time of writing is specific to Ingenii's extended version of dbt-spark==0.19.1. More details are given below.

### `dbt_project.yml`

There are two settings that need to remain fixed:

 - `profile`: This must be set to `databricks` to match the entry in profiles.yml.
 - `log-path`: This must be set to `/tmp/dbt-logs`. Part of the file ingestion pipeline will move these logs to a mounted container, and expects the logs to be in this file.

There are other settings that you will add as you implement your data model. To integrate well and make the data available in the whole platform, there are some requirements to follow:

- `models` and `snapshots` must be tables, and not views. This will mean that the data is written to files, which can then be made available to both the Engineering and Analysis Databricks workspaces.
- `models` and `snapshots` must be written to a specified location, so that the data is stored on the Data Lake. To aid this, there are two folders made available in Databricks: `/mnt/models` and `/mnt/snapshots`. Our recommended approach is to specify a folder per schema, and so set the `location_root` setting as `/mnt/models/<schema name>`. Data will then be stored at the path `/mnt/models/<schema name>/<table name>`. If a model or snapshot has no schema, it should be written to `/mnt/models/default` to keep the folder structure.

In the example folder structure below, we create a subfolder per schema to help `dbt` to know which schema each table belongs to.
```
dbt
|
└─ models
| |  
| └─ schemaA
| |    table1.sql
| |    table2.sql
| |  
| └─ schemaB
| |    table3.sql
| |    table4.sql
|
└─ snapshots
| |  
| └─ schemaC
| |    snapshot1.sql
|
| dbt_project.yml
| profiles.yml
```

To match this, in the `dbt_projects.yml` file we set the following configuration:

```yml
name: 'example_dbt_project'

. . . 

# Project Level Configs
models:
  example_dbt_project:
    file_format: delta # To use Databricks' Delta Lake
    materialized: table # All models written to the Data Lake
    schemaA: # Folder name
      schema: schemaa # Specify the schema name, always lower case
      location_root: /mnt/models/schemaa # Location on the mounted Data Lake container
      # Tables will be stored at /mnt/models/schemaa/table1 and /mnt/models/schemaa/table2 in the Databricks file system
      # These correspond to /schemaa/table1 and /schemaa/table2 of the 'models' container in the Data Lake
    schemaB: # Folder name
      schema: schemab # Specify the schema name, always lower case
      location_root: /mnt/models/schemab # Location on the mounted Data Lake container
      # Tables will be stored at /mnt/models/schemab/table3 and /mnt/models/schemab/table4 in the Databricks file system
      # These correspond to /schemab/table3 and /schemab/table4 of the 'models' container in the Data Lake
  
snapshots:
  example_dbt_project:
    file_format: delta # To use Databricks' Delta Lake
    schemaC: # Folder name
      location_root: /mnt/snapshots/schemac  # Location on the mounted Data Lake container
      # Snapshot will be stored at /mnt/snapshots/schemac/snapshot1 in the Databricks file system
      # This corresponds to /schemac/snapshot1 of the 'snapshots' container in the Data Lake
```

We can apply this to `dbt`'s [jaffle_shop example](https://github.com/dbt-labs/jaffle_shop). The relevant parts of the original `dbt_project.yml` is :
```yml
name: 'jaffle_shop'

. . . 

models:
  jaffle_shop:
    materialized: table
    staging:
      materialized: view
```

None of the tables have a schema assosicated to them, so our updated  `dbt_project.yml` is:
```yml
name: 'jaffle_shop'

. . . 

models:
  jaffle_shop:
    file_format: delta # To use Databricks' Delta Lake
    materialized: table
    location_root: /mnt/models/default # With no specific schema, the tables are written to the 'default' folder
    staging:
      materialized: table # Changed from 'view'. This and the line above could be removed to inherit from the lines above 
```

### retry_all flag

When running `dbt` tests, if there are a lot of tests associated with a table we've found that a few will fail randomly due to intermittent connection issues. By default `dbt-spark` will only retry a request if it deems the error it receives 'retryable' - usually when the message refers to the cluster starting up - so we have implemented this `retry_all` flag, which will always retry the test failures. We recommend that this is set to `true`.

For posterity, [our pull request to update dbt-spark is here](https://github.com/dbt-labs/dbt-spark/pull/194).

## Data Integration

We have an example schema.yml in `models/random_data/` to showcase what we need to integrate `dbt` with Databricks and the Ingenii Data Engineering pipelines. All data we want the platform to know about should be recorded as [dbt sources](https://docs.getdbt.com/docs/building-a-dbt-project/using-sources), where we specify each of the tables and their schemas in one or more `schema.yml` files. The folder structure for these files needs to be `models/<source or data provider name>/<table name>.yml`. These files are read by the pipelines to ingest the raw data files into the Data Platform environment. 

For the general schema, please see the [dbt documentation for sources](https://docs.getdbt.com/reference/source-properties). In order to integrate with our data platform, there are certain settings that are required, and some additions made to the `dbt` schema to better understand the files we are ingesting.

```yml
version: 2

sources:
  - name: random_example
    schema: random_example
    tables:
      - name: alpha
        external:
          using: "delta"
        join:
          type: merge
          column: "date"
        file_details:
          sep: ","
          header: false
          dateFormat: dd/MM/yyyy
        columns:
          - name: date
            data_type: "date"
            tests: 
              - unique
              - not_null
          - name: price1
            data_type: "decimal(18,9)"
            tests: 
              - not_null
          - name: price2
            data_type: "decimal(18,9)"
            tests: 
              - not_null
          - name: price3
            data_type: "decimal(18,9)"
            tests: 
              - not_null
          - name: price4
            data_type: "decimal(18,9)"
            tests: 
              - not_null
```
### Schema: Sources
Each source must have the following keys:
  1. `name`: The name of the source or data provider
  1. `schema`: The schema to load the tables to in the database. Keep this the same as the name
  1. `tables`: A list of each of the tables that we will ingest

### Schema: Tables
Each table within a source must have the following keys:
  1. `name`: The name of the table
  1. `external`: This sets that this is a delta table, and is stored in a mounted container. Always include this object as it is here.
  1. `join`: object to define how we should add new data to the main source table. The `column` entry will accept a comma-separated list of column names, if more than one forms the primary key. We have a few options for the `type`:
      1. `merge_insert`: This will only insert new rows, as long as the entry does not already exist based on the `column` entry.
      1. `merge_update`: This will insert new rows and update existing ones, matching based on the `column` entry.
      1. `insert`, or not set: all rows in each file will be inserted, regardless if this causes a duplicate.
  1. `file_details`: Gives general information about the source file to help read it. These entries are passed to, and so must follow the conventions of, the [pyspark.sql.DataFrameReader.csv](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.sql.DataFrameReader.csv.html#pyspark.sql.DataFrameReader.csv) function. 'path' and 'schema' are set separately, so do not set these or the 'inferSchema' and 'enforceSchema' parameters. Some example parameters are below:
      1. `sep`: When reading the source files, this is the field separator. For example, in comma-separated values (.csv), this is a comma ','
      1. `header`: boolean, whether the source files have a header row
      1. `dateFormat`: The format to convert from strings to date types. 
      1. `timestampFormat`: The format to convert from strings to datetimes types. 
  1. `columns`: A list of all the columns of the file. Schema is detailed in the section below

### Schema: Columns
For each table all columns need to be specified, and each must have the following keys: 
  1. `name`: The name of the column
  1. `data_type`: The data type we expect the column to be, using [Databricks SQL data types](https://docs.microsoft.com/en-us/azure/databricks/spark/latest/spark-sql/language-manual/sql-ref-datatypes#sql)
  1. `tests`: A list of any [dbt tests](https://docs.getdbt.com/docs/building-a-dbt-project/tests) that we want to apply to the column on ingestion

## dbt Resources:
- Learn more about `dbt` [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on `dbt`'s development and best practices
