# New Data Source

If we want to ingest new data into the platform we need to set the configuration so the platform can understand this new data. If a file is uploaded into the `raw` container in the data lake the platform will try to ingest it, and will refer to the `dbt` and `pre_process` information to understand how to read, process, and test the data in the file.

Since this is a repository, changes to add or update your data sources should be made on a new development branch. This gives space to work and test your configuration, before merging the branch into the `main` branch, making the code production ready. This branch can be used for changes in all of the 3 sections below, and the overall steps are:

1. Create a new branch on the repository, wither through the DevOps UI or through your git CLI.
1. Make the required changes to the different files as described in the below sections. Commit and push your changes to the development branch. CI/CD will deploy these changes into your Development environment.
1. Once you are satisfied with and havbe tested all of your changes, open and merge a pull request between your development branch and the `main` branch.
1. The CI/CD pipeline will deploy your resources into you production environment.

## Creating a new pipeline to get data

Once you know what data you want to pull into the platform the first step is to get it into your Azure cloud environment. The goal of this step is to get files (.csv, .json) into the `raw` container of the data lake so that they can be ingested. The files need to be added to the folder path `<data provider name>/<table name>`, where each file has a unique name within this folder. More details about why this is crucial is covered in the `Understanding and ingesting into the platform` section.

If you already have a system for getting the files into the right place, then once you've got it set up you can move to the next section. However, if you need a pipeline to obtain the data, then you may be able to use the Azure Data Factory Generator. The basic steps to implement this are below, and full details and configuration can be found in the [Pipeline Generation](./pipeline_generation.md) documentation.

1. Check the [Azure Data Factory Generator documentation](https://github.com/ingenii-solutions/azure-data-factory-generator/blob/main/docs/user/ADFGUSAGE.md) to see if it supports the type of connector you need to use, such as SFTP or a type of API call. If it's not there, please [raise an issue on the GitHib page](https://github.com/ingenii-solutions/azure-data-factory-generator/issues) so we know to add it in.
1. Create any required resources, such as adding a password to the relevant Azure Key Vault so that the pipelines can access it.
1. Create the configuration file in the `pipeline_generation` folder to represent the data provider.
1. Generate the Data Factory resources with the `make create-data-factory-objects` command, and commit these to the repository.
1. The CI/CD pipeline will deploy these new resources to your Development Azure Data Factory instance. Check that all looks good, and ideally test the functionality.

## Pre-processing the raw data

Currently, the data platform can only ingest files in a few forms, and it's likely that the raw data you receive from your data file needs to be changed to match these forms. If this is the case, then the pre-processing step is where you can add python code which the data pipeline will run against your files before they are ingested into the platform. Full details about how this works and how you can add your code can be found in the [Pre-Processing](./pre_process.md) documentation.

## Understanding and ingesting into the platform

The final section that needs to be configured is setting definitions so that the platform can both read the source files and set the properties of the tables in the Databricks environment. Full details can be found in the [Understanding and Ingesting Data](./Understanding_and_Ingesting_Data.md) documentation.
