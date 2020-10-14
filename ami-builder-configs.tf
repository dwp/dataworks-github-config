resource "github_repository" "ami-builder-configs" {
  name        = "ami-builder-configs"
  description = "Configuration files for building various AMIs using ami-builder"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ami-builder-configs-dataworks" {
  repository = github_repository.ami-builder-configs.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "ami-builder-configs-master" {
  branch         = github_repository.ami-builder-configs.default_branch
  repository     = github_repository.ami-builder-configs.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "ami-builder-configs" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.ami-builder-configs.name
}

resource "github_repository_webhook" "ami-builder-configs" {
  repository = github_repository.ami-builder-configs.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/github-config/resources/${github_repository.ami-builder-configs.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "ami-builder-configs-pr" {
  repository = github_repository.ami-builder-configs.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/github-config/resources/${github_repository.ami-builder-configs.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
