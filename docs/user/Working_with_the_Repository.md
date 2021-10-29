# Working with the Data Engineering repository

Following normal git practices, changes to add or update your data sources should be made on a new development branch which gives space to work and test your configuration. This development branch should be used for all the configurations needed to add or update a data source, from geting the raw data, to pre-processing, to definition and ingesting.

Here we don't intend to give you a full explanation of how git works, as there's plenty of good resources already written that don't need repeating. We do want to give an overview of how to interact with the  

When you're happy with your changes we merge the branch into the `main` branch, signifying that the code is production ready.

The overall steps are:

1. Create a new branch on the repository, whether through the DevOps UI or through your git CLI.
1. Make the required changes to the different files as described in the below sections. Commit and push your changes to the development branch. CI/CD will deploy these changes into your Development environment.
1. Once you are satisfied with and havbe tested all of your changes, open and merge a pull request between your development branch and the `main` branch.
1. The CI/CD pipeline will deploy your resources into you production environment.
