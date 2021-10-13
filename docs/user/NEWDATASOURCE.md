# New Data Source

If we want to ingest new data into the platform we need to set the configuration so the platform can understand this new data. If a file is uploaded into the `raw` container in the data lake the platform will try to ingest it, and will refer to the `dbt` and `pre_process` information to understand how to read, process, and test the data in the file.

The full details of how the different sections work are held in the relevant documentation:
1. [Pipeline Generation](./PIPELINEGENERATION.md)
1. [Pre-Processing](./PREPROCESS.md)
1. [dbt](./DBT.md)
