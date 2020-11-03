resource "github_repository" "dataworks_s3_data_purger" {
  name             = "dataworks-s3-data-purger"
  description      = "Lambda for deleting old redundant S3 data"
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

resource "github_team_repository" "dataworks_s3_data_purger_dataworks" {
  repository = github_repository.dataworks_s3_data_purger.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_s3_data_purger_master" {
  branch         = github_repository.dataworks_s3_data_purger.default_branch
  repository     = github_repository.dataworks_s3_data_purger.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_s3_data_purger" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_s3_data_purger.name
}

resource "null_resource" "dataworks_s3_data_purger" {
  triggers = {
    repo = github_repository.dataworks_s3_data_purger.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_s3_data_purger.name} '${github_repository.dataworks_s3_data_purger.description}' ${github_repository.dataworks_s3_data_purger.template.0.repository}"
  }
}
