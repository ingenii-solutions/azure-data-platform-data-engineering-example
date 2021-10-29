# New Data Source

- [New Data Source](#new-data-source)
  - [Tools required](#tools-required)
  - [Working with the Data Engineering repository](#working-with-the-data-engineering-repository)
  - [Creating a new pipeline to get data](#creating-a-new-pipeline-to-get-data)
  - [Pre-processing the raw data](#pre-processing-the-raw-data)
  - [Understanding and ingesting into the platform](#understanding-and-ingesting-into-the-platform)

This document outlines how to get a new data source into your Ingenii Azure Data Platform: from obtaining the data with Data Factory pipelines, to pre-processing the raw data if required, to defining the data schema so the platform can ingest this data and create the resulting tables in Databricks.

If we want to ingest new data into the platform we need to set the configuration so the platform can understand this new data. If a file is uploaded into the `raw` container in the data lake the platform will try to ingest it, and will refer to the `dbt` and `pre_process` information to understand how to read, process, and test the data in the file.

## Tools required

Azure CLI
git
make



## Working with the Data Engineering repository

Following normal git practices, changes to add or update your data sources should be made on a new development branch which gives space to work and test your configuration. This developement branch should be used for changes in all of the 3 sections below.

When you're happy with your changes we merge the branch into the `main` branch, signifying that the code is production ready.

The overall steps are:

1. Create a new branch on the repository, whether through the DevOps UI or through your git CLI.
1. Make the required changes to the different files as described in the below sections. Commit and push your changes to the development branch. CI/CD will deploy these changes into your Development environment.
1. Once you are satisfied with and havbe tested all of your changes, open and merge a pull request between your development branch and the `main` branch.
1. The CI/CD pipeline will deploy your resources into you production environment.

## Creating a new pipeline to get data

Once you've decided what data you want to pull into the platform the first step is to get it into your Azure cloud environment. The goal of this step is to get files (.csv, .json) into the `raw` container of the data lake so that they can be ingested. The files need to be added to the folder path `<data provider name>/<table name>`, where each file has a unique name within this folder. More details about why this is crucial is covered in the `Understanding and ingesting into the platform` section.

If you already have a system for getting the files into the right place, then once you've got it set up you can move to the next section. However, if you need a pipeline to obtain the data, then you may be able to use the Azure Data Factory Generator. The steps to add or update a data source are in the [Pipeline Generation](./pipeline_generation.md) documentation.

## Pre-processing the raw data

Currently, the data platform can only ingest files in a few forms, and it's likely that the raw data you receive from your data file needs to be changed to match these forms. If this is the case, then the pre-processing step is where you can add python code which the data pipeline will run against your files before they are ingested into the platform. Full details about how this works and how you can add your code can be found in the [Pre-Processing](./pre_process.md) documentation.

## Understanding and ingesting into the platform

The final section that needs to be configured is setting definitions so that the platform can both read the source files and set the properties of the tables in the Databricks environment. Full details can be found in the [Understanding and Ingesting Data](./Understanding_and_Ingesting_Data.md) documentation.
