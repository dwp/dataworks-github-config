resource "github_repository" "analytical_env_hive_custom_auth" {
  name        = "analytical-env-hive-custom-auth"
  description = "DataWorks Analytical Environment custom authentication proivder for HiveServer 2"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "analytical_env_hive_custom_auth_dataworks" {
  repository = github_repository.analytical_env_hive_custom_auth.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "analytical_env_hive_custom_auth_master" {
  branch         = github_repository.analytical_env_hive_custom_auth.default_branch
  repository     = github_repository.analytical_env_hive_custom_auth.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "analytical_env_hive_custom_auth" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.analytical_env_hive_custom_auth.name
}

resource "null_resource" "analytical_env_hive_custom_auth" {
  triggers = {
    repo = github_repository.analytical_env_hive_custom_auth.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.analytical_env_hive_custom_auth.name} '${github_repository.analytical_env_hive_custom_auth.description}' ${github_repository.analytical_env_hive_custom_auth.template.0.repository}"
  }
}

resource "github_actions_secret" "analytical_env_hive_custom_auth_snyk_token" {
  repository      = github_repository.analytical_env_hive_custom_auth.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "analytical_env_hive_custom_auth_slack_webhook" {
  repository      = github_repository.analytical_env_hive_custom_auth.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}
