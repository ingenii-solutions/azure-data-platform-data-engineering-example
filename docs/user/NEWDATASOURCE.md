# New Data Source

If we want to ingest new data into the platform we need to set the configuration so the platform can understand this new data. If a file is uploaded into the `raw` container in the data lake the platform will try to ingest it, and will refer to the `dbt` and `pre_process` information to understand how to read, process, and test the data in the file.

The full details of how the different sections work are held in the relevant documentation:
1. [dbt](./DBT.md)
1. [Pre-Processing](./PREPROCESS.md)
1. [Pipeline Generation](./PIPELINEGENERATION.md)
In this document we detail the steps to add a new data source, or update an existing one.

## Pipeline Generation

## Pre-Processing

## dbt

New schema file to correspond to the new data file
Folder structure must be `models/<source name>/<table name>.yml`
File contains the column structure of the data
