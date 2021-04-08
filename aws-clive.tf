resource "github_repository" "aws_clive" {
  name             = "aws_clive"
  description      = "aws_clive"
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
    repository = "aws-emr-template-repository"
  }
}

resource "github_team_repository" "aws_clive_dataworks" {
  repository = github_repository.aws_clive.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_clive_master" {
  branch         = github_repository.aws_clive.default_branch
  repository     = github_repository.aws_clive.name
  enforce_admins = false

  required_status_checks {
    strict = true
    contexts = ["docker-build-and-scan"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws_clive" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_clive.name
}

resource "null_resource" "aws_clive" {
  triggers = {
    repo = github_repository.aws_clive.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_clive.name} '${github_repository.aws_clive.description}' ${github_repository.aws_clive.template.0.repository}"
  }
}

resource "github_actions_secret" "aws_clive_dockerhub_password" {
  repository      = github_repository.aws_clive.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "aws_clive_dockerhub_username" {
  repository      = github_repository.aws_clive.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "aws_clive_snyk_token" {
  repository      = github_repository.aws_clive.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
