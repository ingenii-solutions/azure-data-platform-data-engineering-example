# Ingenii Azure Data Platform Data Engineering Example
An example repository for using with [Ingenii's Azure Data Platform Databricks Runtime](https://github.com/ingenii-solutions/azure-data-platform-databricks-runtime).

Here we keep a record of the required settings to configure your data engineering pipelines, which split into two main sections:
   1. Pre-processing functions to run on raw files, say a JSON file returned by an API that needs to be converted to a .csv [PREPROCESS.md](pre_process/PREPROCESS.md)
   1. `dbt` configuration for the Databricks tables and ingestion pipelines [DBT.md](dbt/DBT.md)
