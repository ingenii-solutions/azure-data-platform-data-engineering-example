# Ingenii Azure Data Platform Data Engineering Example
An example repository for using with [Ingenii's Azure Data Platform Databricks Runtime](https://github.com/ingenii-solutions/azure-data-platform-databricks-runtime). You should clone this into your own Azure DevOps repository and add your data-specific configuration to integrate with [Ingenii's Azure Data Platform](https://ingenii.dev/).

Here we keep a record of the required settings to configure your data engineering pipelines, which are contianed in three folders:
   1. `dbt`: Configuration for the Databricks tables and source data files: [DBT.md](docs/user/DBT.md)
   1. `pipeline_generation`: Configurations of pipelines which can be generated using the [Ingenii Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator): [PIPELINEGENERATION.md](docs/user/PIPELINEGENERATION.md)
   1. `pre_process`: Functions to run on raw files to prepare them to be ingested by the data platform. For example, rewrite a JSON file returned by an API that needs to be converted to a .csv: [PREPROCESS.md](docs/user/PREPROCESS.md)
