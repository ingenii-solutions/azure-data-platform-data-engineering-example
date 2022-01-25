# Ingenii Azure Data Platform Data Engineering Example
An example repository for using with [Ingenii's Azure Data Platform Databricks Runtime](https://github.com/ingenii-solutions/azure-data-platform-databricks-runtime). You should clone this into your own Azure DevOps repository and add your data-specific configuration to integrate with [Ingenii's Azure Data Platform](https://ingenii.dev/).

Here we keep a record of the required settings to ignest raw data into your data platform, which are contained in these folders:
   1. `dbt`: Configuration for the Databricks tables and source data files: [Understanding_and_Ingesting_Data.md](docs/user/Understanding_and_Ingesting_Data.md)
   1. `pre_process`: Python code to prepare raw files to be ingested by the data platform. For example, these could rewrite a JSON file returned by an API that needs to be converted to a `.csv`: [Pre_Processing.md](docs/user/Pre_Processing.md)
