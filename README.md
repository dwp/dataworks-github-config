# dataworks-github-config
Manage GitHub team and repository configuration for DataWorks

# Concourse Pipeline
For this repo, Concourse pipeline config is auto generated using Python, Jinja and Spruce.
To update the pipeline run `make pipeline`

# Initialise issue

In order to create empty repo's you need to add the `auto_init` line in the repo's .tf file.
```
resource "github_repository" "my-new-repo" {
  name        = "my-new-repo"
  description = "Description of my new repo"
  auto_init   = true
```  
