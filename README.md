# dataworks-github-config
Manage GitHub team and repository configuration for DataWorks

## How to create a new GitHub repository for the DataWorks Project

1. Note that at the moment you *must* use a UC Mac for the following procedure,
   with access to the Crown Concourse infrastructure. Once Concourse moves to
   AWS this restriction will be lifted.
1. Copy `repository.tf.sample` to a new `.tf` file [1]
1. Update the `github_repository` resource name, and its `name` and `description` attributes. *Do not* make any other changes.
1. Update the 3 references to the `github_repository` resource so their names match the new name you used in step 2.
1. Make sure all `example` entries are replaced with new repo name as used in step 3.
1. The `contexts` line in the `required_status_checks` stanza should only be kept for Terraform repos. 
   1. If the new repo will not contain terraform, remove the `contexts` line.
1. Run `make pipeline` to update the Concourse pipeline [2]. This step will also:
   1. Override any githooks with [canoncial copies](.githooks)
   1. Commit a Makefile with common `bootstrap` actions
1. Raise a PR with your changes
1. Once approved and merged, Concourse should create your new repository
1. If your repository is for Terraform code, you will need to update the newly committed `Makefile` with some Terraform bootstrapping commands.
   [aws-concourse](https://github.com/dwp/aws-concourse/blob/master/Makefile) is a decent source of inspiration.
1. Run `make bootstrap` from within the top level directory of your new repo

# Notes

1. Our early repository configs didn't ask for them to be initialized by Terraform, which led to a 2-step terraform run (once without the branch protection configured, and then, once the repo had been created, with branch protection turned on). Those configuration files now can't be changed, because changing that config setting tries to delete the repository and recreate them. Thankfully, they're protected by a `lifecycle` guard so that doesn't actually happen. In short, *always* copy the `repository.tf.sample` and not just any other existing `.tf` file.
1. You will need Python, Jinja, Spruce and Aviator installed to successfully generate and apply the new updated Concourse pipelines.
