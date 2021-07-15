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
   1. For Terraform repos also update the `local.example_pipeline_name` key and value. This allows the pipeline name to differ from the repo, and typically be a shorter name.
1. Raise a PR with your changes
1. Once approved and merged, the concourse job for this repo (not your new one) will run and create your new repository. This takes a while as it checks all repos configured here.

## Post Repo Creation
After the repo has been created you need to do the follwoing:
### For all repos:
* Create the project on SonarCloud
  1. Go to https://sonarcloud.io/projects/create (sign in with GitHub).  If you are unable to use SonarCloud with DWP 
     GitHub, you may need to be added to the DataWorks Team on SonarCloud
  1. Find your new repo(s) in the lists, select it and choose "Set Up" in the right-hand margin
  1. There will be very little code at this point, but click the "More Information" and "Force Automatic Analysis" buttons to override the warning
* Request that the repo is added to the [DataWorks Slack notification](https://github.com/organizations/dwp/settings/reminders/12081)
  1. Send the above link to a [GitHub organisation owner](https://github.com/orgs/dwp/people?query=role%3Aowner) and ask them to add the new repo to the list

### For Docker repos:
* Create a repo on Docker Hub
  1. Create the Docker repo in the [dwpdigital](https://hub.docker.com/u/dwpdigital) team
  1. After creating the repo go to the permissions tab and grant the `dataworks` team `admin` access

### Naming convention
Repo names should avoid using any technology within its name, incase the technology changes which would lead to confusion.
Infrastructure repos should be prefixed with `dataworks-aws`.
Application repos should not be prefixed with `dataworks-aws`.

# Notes

1. You will need Python, Jinja, Spruce and Aviator installed to successfully generate and apply the new updated Concourse pipelines.

# In regards to Secrets (AWS Concourse)

Secrets are _all_ managed via SecretsManager. See: [dataworks-secrets](https://github.ucds.io/dip/dataworks-secrets)


## Renaming terraform state files
If you need to rename the terraform state file for any reason:

1) Rename the state file in S3 while no pipelines are rolling out.
2) Update the repo terraform.tf.j2 backend s3 resource key value to the new state file name.
3) PR / Terraform apply out to the environment - there should be no infrastructure changes.
