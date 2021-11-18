# Pipeline Generation

All files you want to ingest into the platform need to be uploaded to the `raw` container in your data lake. If you already have a system to do this then you should be able to skip this section; if not we have built the [Ingenii Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator) to easily create and manage Data Factory pipelines to get data and write it to files in your data lake.

- [Adding or updating a data source](#adding-or-updating-a-data-source) - adding a new pipeline and the objects to support it
- [Deployment](#deployment) - deploying your objects to the Data Factory in different environments

## Adding or updating a data source

In your data engineering repository you can create the configurations that the [Ingenii Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator) package will read to create the pipelines and other objects we can deploy to Data Factory to pull data into your data platform. Every `.json` file in the `pipeline_generation` folder corresponds to an individual data source; several tables can be defined in one file. The steps to follow are:

1. Check the [Azure Data Factory Generator documentation](https://github.com/ingenii-solutions/azure-data-factory-generator/blob/main/docs/user/Usage.md) to see if it supports the type of connector you need to use, such as SFTP or a type of API call. If it's not there, please [raise an issue on the GitHib page](https://github.com/ingenii-solutions/azure-data-factory-generator/issues) so we know to add it in.
1. Create any external required resources, such as adding a password to the relevant Azure Key Vault so that the pipelines can access it. What each pipeline requires is detailed in the [Azure Data Factory Generator documentation](https://github.com/ingenii-solutions/azure-data-factory-generator/blob/main/docs/user/Usage.md).
1. In the `pipeline_generation` folder, if you want to add a new data source then create a new file, or if you want to update an existing data source by adding tables or changing the configuration then edit the respective file.
1. Generate the Data Factory resources by running `make create-data-factory-objects` from the root of the repository, which will create the required `.json` files in subfolders in the `pipeline_generation` folder.
1. Deploy these created items to the Development Data Factory so we can test the changes. The CI/CD pipeline will deploy these new resources, but if there are any issues please see the [Deployment](#deployment) section below for an approach to upload these manually.
1. In the Development Data Factory check that your functionality is working as it should.
1. Once you're happy, the last step will be opening a pull request to merge the development branch to the `main` branch, and so deploy your changes to the Production Data Factory. As we say in the [Introduction documentation](./Introduction.md), this branch should include changes to other parts of the repository, so it makes sense to make sure all changes are working as they should before merging the branch.

## Deployment

Since some resources refer to other ones, the deployment of each 'class' of resource needs to happen in a specific order, namely:

1. integration runtimes
2. linked services
3. datasets
4. pipelines
5. triggers

Deployment is made through the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/), either through the CI/CD pipeline or deployed manually. Example code to deploy these resources is given below, from the context within the `pipeline_generation/` folder and using a Linux terminal:

```bash
RESOURCEGROUP=<resource group name>
DATAFACTORY=<data factory name>

FILES="integrationRuntime/*"
for f in $FILES
do
  az datafactory integration-runtime managed create --resource-group "$RESOURCEGROUP" --factory-name "$DATAFACTORY" --integration-runtime-name "$(echo $f | awk -F '/' '{ print $2 }' | sed 's/.json//')" --compute-properties "$(cat $f | jq '.properties')"
done

FILES="linkedService/*"
for f in $FILES
do
  az datafactory linked-service create --resource-group "$RESOURCEGROUP" --factory-name "$DATAFACTORY" --linked-service-name "$(echo $f | awk -F '/' '{ print $2 }' | sed 's/.json//')" --properties "$(cat $f | jq '.properties')"
done

FILES="dataset/*"
for f in $FILES
do
  NAME="$(echo $f | awk -F '/' '{ print $2 }' | sed 's/.json//')"
  az datafactory dataset create --resource-group "$RESOURCEGROUP" --factory-name "$DATAFACTORY" --dataset-name "$NAME" --properties "$(cat $f | jq '.properties')"
done

FILES="pipeline/*"
for f in $FILES
do
  az datafactory pipeline create --resource-group "$RESOURCEGROUP" --factory-name "$DATAFACTORY" --name "$(echo "$f" | awk -F '/' '{ print $2 }' | sed 's/.json//')" --pipeline "$(cat "$f" | jq '.properties')"
done

FILES="trigger/*"
for f in $FILES
do
  az datafactory trigger create --resource-group "$RESOURCEGROUP" --factory-name "$DATAFACTORY" --trigger-name "$(echo $f | awk -F '/' '{ print $2 }' | sed 's/.json//')" --properties "$(cat $f | jq '.properties')"
done
```
Each block in the code above will loop through each file in the related `generated` folder, and create or update the resource in the set Data Factory.
