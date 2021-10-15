# Pipeline Generation

This section is not necessary if you already have a pipeline to load files into the `raw` container in your data lake. If you do need a pipeline, we have built the [Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator) to easily create and manage pipelines to pull data into the platform. See the [usage documentation](https://github.com/ingenii-solutions/azure-data-factory-generator/docs/user/ADFGUSAGE.md) for information of how the package works.

In your data engineering repository you can create the configurations that the [Ingenii Azure Data Factory Generator](https://github.com/ingenii-solutions/azure-data-factory-generator) package will read to create the pipelines and other objects we can deploy to Data Factory to pull data into your data platform.

## Configuration

Every `.json` file in the `pipeline_generation` corresponds to an individual data source; several tables can be defined in one file. If you want to add a new data source then create a new file; if you want to update an existing data source by adding tables or changing the configuration then update the relevant `.json` file.

When your configuration is set correctly, run the command:
```
make create-data-factory-objects
```
This will create or update any objects within the `pipeline_generation/` folder, in sub-folders specific to the object type, which will need to be deployed to the relevant Data Factory resources.

## Deployment

Since some resources refer to other ones, the deployment of each 'class' of resource needs to happen in a specific order, namely:

1. integration runtimes
1. linked services
1. datasets
1. pipelines
1. triggers

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
