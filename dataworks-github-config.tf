resource "github_repository" "dataworks-github-config" {
  name        = "dataworks-github-config"
  description = "Manage GitHub team and repository configuration for DataWorks"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-github-config-dataworks" {
  repository = "${github_repository.dataworks-github-config.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks-github-config-master" {
  branch         = "${github_repository.dataworks-github-config.default_branch}"
  repository     = "${github_repository.dataworks-github-config.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_repository_webhook" "dataworks-github-config" {
  repository = "${github_repository.dataworks-github-config.name}"
  events     = ["push"]

  configuration {
    url          = "https://ci.dataworks.dwp.gov.uk/api/v1/teams/dataworks/pipelines/dataworks-github-config/resources/dataworks-github-config/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks-github-config-pr" {
  repository = "${github_repository.dataworks-github-config.name}"
  events     = ["pull_request"]

  configuration {
    url          = "https://ci.dataworks.dwp.gov.uk/api/v1/teams/dataworks/pipelines/dataworks-github-config/resources/dataworks-github-config-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
