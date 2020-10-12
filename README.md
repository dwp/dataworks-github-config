# dataworks-github-config
Manage GitHub team and repository configuration for DataWorks

## How to create a new GitHub repository for the DataWorks Project

This process is currently intended for use with *public*, not private repositories.

1. There are now standards for creating a new repository, dependant on type:
   - _*Terraform repositories:*_ Copy `terraform-template-repository.tf.sample` to a new `.tf` file to create a standard Terraform repository, including Terraform templates and CI pipeline.
   - _*Docker repositories:*_ Copy `docker-template-repository.tf.sample` to a new `.tf` file to create a standard Docker repository, including GitHub Actions pipeline.  
      - Follow the standard naming policy for container images and their VCS repositories to be identically named.
   - _*All other repositories:*_ Copy `template-repository.tf.sample` to a new `.tf` file to create a standard empty repository
1. Update the `github_repository` resource name (example) using underscores as separators if required. Its `name`  should use hyphen separators if required, and `description` attributes should be a single sentence. 
1. Replace every instance of `example` with the name of your repo using underscores.
1. Raise a PR with your changes
1. Once approved and merged, the concourse job for this repo (not your new one) will run and create your new repository. This takes a while as it checks all repos configured here.

## Post Repo Creation
After the repo has been created you need to do the follwoing:
### For all repos:
1. Create the project on SonarCloud
1.1. Go to https://sonarcloud.io/projects/create (sign in with GitHub)
1.1. Find your new repo(s) in the lists, select it and choose "Set Up" in the right hand margin
1.1. There will be very little code at this point, but click the "Force Automatic Analysis" button to ovveride the warning

### For Docker repos:
1. Create a repo on Docker Hub
1.1. Create the Docker repo in the [dwpdigital](https://hub.docker.com/u/dwpdigital) team
1.1. After creating the repo go to the permissions tab and grant the `dataworks` team `admin` access

# Notes

1. You will need Python, Jinja, Spruce and Aviator installed to successfully generate and apply the new updated Concourse pipelines.

# In regards to Secrets (AWS Concourse)

Secrets are _all_ managed via SecretsManager. See: [dataworks-secrets](https://github.ucds.io/dip/dataworks-secrets)
