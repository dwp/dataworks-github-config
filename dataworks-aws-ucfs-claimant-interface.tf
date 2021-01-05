resource "github_repository" "dataworks_aws_ucfs_claimant_interface" {
  name             = "dataworks-aws-ucfs-claimant-interface"
  description      = "AWS lambda to provide an interface with the UCFS Claimant API database."
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "dataworks_aws_ucfs_claimant_interface_dataworks" {
  repository = github_repository.dataworks_aws_ucfs_claimant_interface.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_aws_ucfs_claimant_interface_master" {
  branch         = github_repository.dataworks_aws_ucfs_claimant_interface.default_branch
  repository     = github_repository.dataworks_aws_ucfs_claimant_interface.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_aws_ucfs_claimant_interface" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_aws_ucfs_claimant_interface.name
}

resource "null_resource" "dataworks_aws_ucfs_claimant_interface" {
  triggers = {
    repo = github_repository.dataworks_aws_ucfs_claimant_interface.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_aws_ucfs_claimant_interface.name} '${github_repository.dataworks_aws_ucfs_claimant_interface.description}' ${github_repository.dataworks_aws_ucfs_claimant_interface.template.0.repository}"
  }
}
