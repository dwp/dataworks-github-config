# dataworks-github-config
Manage GitHub team and repository configuration for DataWorks

## How to create a new GitHub repository for the DataWorks Project

1. Note that at the moment you *must* use a UC Mac for the following procedure,
   with access to the Crown Concourse infrastructure. Once Concourse moves to
   AWS this restriction will be lifted.
1. There are now two standards, for creating a new repository:
   1. _*Non-Terraform repositories:*_ Copy `template-repository.tf.sample` to a new `.tf` file to create a standard empty repository [1]
   1. _*Terraform repositories:*_ Copy `terraform-template-repository.tf.sample` to a new `.tf` file to create a standard Terraform repository, including Terraform templates and CI pipeline. [1]
1. Update the `github_repository` resource name (example) using underscores as separators if required. Its `name`  should use hyphen separators if required, and `description` attributes should be a single sentence. *Do not* make any other changes.
1. Raise a PR with your changes
1. Once approved and merged, the concourse job for this repo (not your new one) will run and create your new repository. This takes a while as it checks all repos configured here.
1. Checkout your new repo and run `make initial-commit` from within the top level directory of your new repo, followed by `aviator` if creating a Terraform repository.  This will rename template files, install the githooks submodule, then create a PR in your new repo.

# Notes

1. You will need Python, Jinja, Spruce and Aviator installed to successfully generate and apply the new updated Concourse pipelines.

# In regards to Secrets (AWS Concourse)

Secrets are _all_ managed via SecretsManager. See: [dataworks-secrets](https://github.ucds.io/dip/dataworks-secrets)
