resource "github_repository" "cloudwatch_agent" {
  name             = "cloudwatch-agent"
  description      = "cloudwatch_agent"
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
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "cloudwatch_agent_dataworks" {
  repository = github_repository.cloudwatch_agent.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "cloudwatch_agent_master" {
  branch         = github_repository.cloudwatch_agent.default_branch
  repository     = github_repository.cloudwatch_agent.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "cloudwatch_agent" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.cloudwatch_agent.name
}

resource "null_resource" "cloudwatch_agent" {
  triggers = {
    repo = github_repository.cloudwatch_agent.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.cloudwatch_agent.name} '${github_repository.cloudwatch_agent.description}' ${github_repository.cloudwatch_agent.template.0.repository}"
  }
}

resource "github_actions_secret" "cloudwatch_agent_dockerhub_password" {
  repository      = github_repository.cloudwatch_agent.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "cloudwatch_agent_dockerhub_username" {
  repository      = github_repository.cloudwatch_agent.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "cloudwatch_agent_snyk_token" {
  repository      = github_repository.cloudwatch_agent.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
