resource "github_repository" "dataworks_ingestion_metadata_interface" {
  name        = "dataworks-ingestion-metadata-interface"
  description = "AWS Lambda to provide an interface to MySQL database that holds ingestion metadata"
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

resource "github_team_repository" "dataworks_ingestion_metadata_interface_dataworks" {
  repository = github_repository.dataworks_ingestion_metadata_interface.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_ingestion_metadata_interface_master" {
  branch         = github_repository.dataworks_ingestion_metadata_interface.default_branch
  repository     = github_repository.dataworks_ingestion_metadata_interface.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_ingestion_metadata_interface" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_ingestion_metadata_interface.name
}

resource "github_actions_secret" "dataworks_ingestion_metadata_interface_github_email" {
  repository      = github_repository.dataworks_ingestion_metadata_interface.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_ingestion_metadata_interface_github_username" {
  repository      = github_repository.dataworks_ingestion_metadata_interface.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "dataworks_ingestion_metadata_interface_github_token" {
  repository      = github_repository.dataworks_ingestion_metadata_interface.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

