resource "github_repository" "dataworks_snapshot_sender_status_checker" {
  name        = "dataworks-snapshot-sender-status-checker"
  description = "An AWS lambda which receives SQS messages and monitors and reports on the status of a snapshot sender run."
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
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "dataworks_snapshot_sender_status_checker_dataworks" {
  repository = github_repository.dataworks_snapshot_sender_status_checker.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_snapshot_sender_status_checker_master" {
  branch         = github_repository.dataworks_snapshot_sender_status_checker.default_branch
  repository     = github_repository.dataworks_snapshot_sender_status_checker.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_snapshot_sender_status_checker" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_snapshot_sender_status_checker.name
}

resource "null_resource" "dataworks_snapshot_sender_status_checker" {
  triggers = {
    repo = github_repository.dataworks_snapshot_sender_status_checker.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_snapshot_sender_status_checker.name} '${github_repository.dataworks_snapshot_sender_status_checker.description}' ${github_repository.dataworks_snapshot_sender_status_checker.template.0.repository}"
  }
}

resource "github_actions_secret" "dataworks_snapshot_sender_status_github_email" {
  repository      = github_repository.dataworks_snapshot_sender_status_checker.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_snapshot_sender_status_github_username" {
  repository      = github_repository.dataworks_snapshot_sender_status_checker.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "dataworks_snapshot_sender_status_checker_snyk_token" {
  repository      = github_repository.dataworks_snapshot_sender_status_checker.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
