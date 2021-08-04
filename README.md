# Ingenii Azure Data Platform dbt Example
An example dbt repository for using with Ingenii's Azure Data Platform.

Here we keep a record of the required settings for dbt to work with the platform. This repository is tested to work with dbt version 0.19.1.

## Usage

### Prerequisites
Your dbt projects needs to be held in an Azure DevOps repository. Create this ahead of working with this repository.

### Start from this repository
One approach is to clone this repository, copy all these files into your new Azure DevOps repository, and then update from this starting point.

### Initialise and update
Instead of clonging this repository, you can intialise your own dbt project in the Azure DevOps repository with the command `dbt init <project name>`, make the configuration changes listed below, and continue from this starting point.

### Configuration additions

profiles.yml:
 - This file stays in the root of the project, rather than in a `/home/<username>/.dbt` folder. This is for simplification
 - `host`, `token`, and `cluster` are drawn from environment variables that are either set by our infrastructure deployment or python package. The profiles.yml file must be set this way, but you don't need to provide any of these variables.
 - `threads` is set to 2, while the default is 5. We've found that when performing a lot of dbt tests the cluster seems to get overloaded and tests will randomly fail. You're free to increase this number, but be warned.
 - One configuration entry is the `retry_all` flag, which at time of writing is specific to Ingenii's extended version of dbt-spark==0.19.1. More details are given below.

#### retry_all flag

When running dbt tests, when there are a lot of tests associated with a table we've found that a few will fail randomly due to intermittent connection issues. At time of writing dbt-spark will only retry a request if it deems the error it receives 'retryable' - usually when the message refers to the cluster starting up.

We have created a fix to allow users to retry all errors when testing, which this flag sets. At time of writing [our PR to update dbt-spark is open](https://github.com/dbt-labs/dbt-spark/pull/194).

### Schema additions

## dbt Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
