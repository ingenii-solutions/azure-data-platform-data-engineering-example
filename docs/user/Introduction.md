# Introduction

This repository holds all of the configuration for how to ingest your data into your Ingenii Azure Data Platform. In this document, and others that this links to, we provide a guide to working with the repository, and how to get a new data source into the platform so you can work with the data in Databricks.

The full data pipeline covers:
1. Pulling raw data into the Data Lake, with Data Factory or similar: [Creating a new pipeline to get data](#creating-a-new-pipeline-to-get-data)
1. Pre-processing the data so that it can be ingested into the platform: [Pre-processing the raw data](#pre-processing-the-raw-data)
1. Reading the metadata so the platform understands how to ingest and test the data: [Understanding and ingesting into the platform](#understanding-and-ingesting-into-the-platform)
1. After this, the ingestion of the individual files is handled by the [Ingenii Azure Data Platform Databricks Runtime](https://github.com/ingenii-solutions/azure-data-platform-databricks-runtime), as these steps all happen on the Databricks platform. These final steps are:
   1. Ingesting the file's data into an individual table
   2. Testing this data
   3. Moving problem data to a separate table
   4. Moving the successful data into the overall table

## Working with the Data Engineering repository

### Tools required

- Operating System: When there is example command line code, it has been written on Linux, specifically `bash`. Windows scripts, either `cmd` or `powershell` or both, will be added soon.
- [git](https://git-scm.com/): This is a git-based repository, so a familarity with this tool is required
- [make](https://www.gnu.org/software/make/) (Optional): For using commands defined in the `Makefile`. For Linux, this is included with most distributions. For Windows, [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm) can be used.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) (Optional): For updating Azure resources or uploading files to storage accounts. This is mainly used by CI/CD pipelines.

### Updating the repository with branches

Following normal git practices, changes to add or update your data sources should be made using a branching strategy, allowing you to make and test changes before merging to your `main` branch and  deploying to your production environment. Azure provides good documentation [for your branching strategy here](https://docs.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance?view=azure-devops).
We recommend that adding or updating your data sources by changing the code should happen on a feature branch, which should be used for all required changes in the 3 sections below. These changes can then be deployed to your development environment where you can test that they are working as expected, after which you can open a pull request to merge the feature branch into the `main` branch, signifying that the code is production ready. At each stage CI/CD pipelines will move your changes into the production environment.

The overall steps are:

1. Create a new branch on the repository, whether through the DevOps UI or through your git CLI.
1. Make the required changes to the different files as described in the below sections. Commit and push your changes to the development branch. CI/CD will deploy these changes into your Development environment.
1. Once you have tested your changes and are satisfied with them, open and merge a pull request between your development branch and the `main` branch.
1. The CI/CD pipeline will deploy your resources into your Production environment.

More details about the CI/CD pipelines can be found in the [CI/CD documentation](./CICD.md).

## Creating a new pipeline to get data

The first step of the pipeline is to get files (.csv, .json) uploaded into the `raw` container of your data lake. The files need to be added to the folder path `<data provider name>/<table name>`, where each file has a unique name within this folder. More details about why this is crucial is covered in the `Understanding and ingesting into the platform` section.

If you already have a system for getting the files into the right place, then you can move to the next section. However, if you need a pipeline to obtain the data then you may be able to use the [Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator), which can create a pipeline and all the required objects from a small configuration file for you. The details to use this are in the [Pipeline Generation](./Pipeline_Generation.md) documentation.

## Pre-processing the raw data

Currently, the data platform can only ingest files in a few forms, and it's likely that the raw data you receive from your data file needs to be changed to match. In the pre-processing step you can add python code which the data pipeline will run against your files before they are ingested into the platform. Full details about how this works and how you can add your code can be found in the [Pre-Processing](./Pre-Process.md) documentation.

## Understanding and ingesting into the platform

The final section that needs to be configured is the metadata so that the platform can both read the raw files and create the tables in the Databricks environment. Full details can be found in the [Understanding and Ingesting Data](./Understanding_and_Ingesting_Data.md) documentation.
