# CI/CD Pipelines

Here we detail the CI/CD pipelines that come with this repository. The different sections are:

- [.yaml Files](#yaml-files) - The files themselves
- [Pipelines](#pipelines) -  The pipelines and their behaviours
- [Virtual machine scale set agents](#virtual-machine-scale-set-agents) - What the pipelines run on. Please read if this is your first time interacting with the repository as it contains a manual step.

## .yaml Files

In the CI/CD folder we have `.yaml` files that define pipelines that will deploy updated code to your different environments. There is no one-size-fits-all approach to CI/CD, so if you want the pipelines to behave differently feel free to change the files, though this will mean that Ingenii will not support this different functionality.

## Pipelines

We supply two sets of pipelines, one for the `dbt` code and one for the `pre-process` code. These then break down into two more pipelines, one for the `development` and `test` environments, and one for `production`.

### Development and Test

This pipeline is called either `Data Engineering - dbt` or `Data Engineering - pre-processing`. The respective pipeline will only trigger if the code changes are in their specific folder. For example, if you make changes to the `dbt` folder, the `dbt` pipeline will run but the `pre-process` pipeline will not.

On code updates to the repository this will automatically deploy to the respective environment: to the `test` environment if the change was made to the main branch, and to `development` if the change is made on any other branch. This allows you to quickly test changes in your `development` environment, and when your changes are complete and you merge to the `main` branch can they be safely tested in your `test` environment, which can catch any problems before the merge to `production`, as described in the next section.

### Production

This pipeline is called either `Data Engineering - dbt - Production` or `Data Engineering - pre-processing - Production`. This pipeline follows the same functionality as the development and test pipeline, except this can only be triggered manually from within Azure DevOps itself. This provides you control in case an issue is found in the test environment and your code is not ready to release.

In Azure DevOps, under the `Pipelines` section, click on the `Pipelines` sub-section and then the pipeline you want to run. In the top right will be a blue `Run pipeline` button, which you can click to deploy to production.

## Virtual machine scale set agents

For CI/CD, the [Ingenii Azure Data Platform](https://ingenii.dev/) will have deployed a [virtual machine scale set](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) called `devops-deployment`, which we assign to Azure DevOps to run the pipelines on. We use a scale set to dynamically create and remove Virtual Machines, keeping costs and maintenance overhead low. This approach is detailed in the [Azure documentation here](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops).

On the Azure DevOps side the scale set has to be assigned as an `Agent pool` for Pipelines to have access to it; unfortunately we cannot do this automatically, so this needs to be done manually at the creation of this project. [The specific part of the Azure documentation that details this process is here](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#create-the-scale-set-agent-pool). We have recommendations to the configuration:
* This pool must be added by a user with permissions over the virtual machine scale set resource itself in your `Shared` Azure subscription.
* The name of the pool must be `DevOps Deployment`, in order to match the pipeline `.yaml` files in the CI/CD folder. This is your repository so if you want to use another name make sure they match in DevOps and the pipeline files.
* We recommend setting `Number of agents to keep on standby` to 0 in order to keep costs low, with the trade-off that pipelines will usually have to wait for a machine to be created in order to run.
* Check `Grant access permission to all pipelines` so that the pipelines can use the pool.
* Other settings can be set as you see fit.

The pipelines themselves will have already been created by our platform, so this is the only manual step required.