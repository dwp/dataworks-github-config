resource "github_repository" "dataworks_sft_agent" {
  name             = "dataworks-sft-agent"
  description      = "A repo for the dataworks sft agent docker image"
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

resource "github_team_repository" "dataworks_sft_agent_dataworks" {
  repository = github_repository.dataworks_sft_agent.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_sft_agent_master" {
  branch         = github_repository.dataworks_sft_agent.default_branch
  repository     = github_repository.dataworks_sft_agent.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_sft_agent" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_sft_agent.name
}

resource "null_resource" "dataworks_sft_agent" {
  triggers = {
    repo = github_repository.dataworks_sft_agent.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_sft_agent.name} '${github_repository.dataworks_sft_agent.description}' ${github_repository.dataworks_sft_agent.template.0.repository}"
  }
}

resource "github_actions_secret" "dataworks_sft_agent_dockerhub_password" {
  repository      = github_repository.dataworks_sft_agent.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "dataworks_sft_agent_dockerhub_username" {
  repository      = github_repository.dataworks_sft_agent.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "dataworks_sft_agent_snyk_token" {
  repository      = github_repository.dataworks_sft_agent.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "dataworks_sft_agent_github_email" {
  repository      = github_repository.dataworks_sft_agent.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_sft_agent_github_username" {
  repository      = github_repository.dataworks_sft_agent.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}



