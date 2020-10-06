resource "github_repository" "docker-jinja-yaml-aws" {
  name        = "docker-jinja-yaml-aws"
  description = "Docker container with Jinja2, YAML and AWS SDK for populating templates with values from AWS"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-jinja-yaml-aws-dataworks" {
  repository = github_repository.docker-jinja-yaml-aws.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-jinja-yaml-aws-master" {
  branch         = github_repository.docker-jinja-yaml-aws.default_branch
  repository     = github_repository.docker-jinja-yaml-aws.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker-jinja-yaml-aws" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker-jinja-yaml-aws.name
}

