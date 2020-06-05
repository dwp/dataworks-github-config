# dataworks-github-config
Manage GitHub team and repository configuration for DataWorks

## How to create a new GitHub repository for the DataWorks Project

1. There are now two standards, for creating a new repository:
   1. _*Non-Terraform repositories:*_ Copy `template-repository.tf.sample` to a new `.tf` file to create a standard empty repository [1]
   1. _*Terraform repositories:*_ Copy `terraform-template-repository.tf.sample` to a new `.tf` file to create a standard Terraform repository, including Terraform templates and CI pipeline. [1]
1. Find and replace all occurrences of the sample Terraform resource (example) using underscores as separators if required. your repos `name`  should use hyphen separators if required, and `description` attributes should be a single sentence. *Do not* make any other changes.
1. Raise a PR with your changes
1. Once approved and merged, the concourse job for this repo (not your new one) will run and create your new repository. This takes a while as it checks all repos configured here.

# Notes

1. You will need Python, Jinja, Spruce and Aviator installed to successfully generate and apply the new updated Concourse pipelines.

# In regards to Secrets (AWS Concourse)

Secrets are _all_ managed via SecretsManager. See: [dataworks-secrets](https://github.ucds.io/dip/dataworks-secrets)
