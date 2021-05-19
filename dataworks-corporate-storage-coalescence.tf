resource "github_repository" "dataworks_corporate_storage_coalescence" {
  name             = "dataworks-corporate-storage-coalescence"
  description      = "Coalesces corporate storage files into larger objects"
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

resource "github_team_repository" "dataworks_corporate_storage_coalescence_dataworks" {
  repository = github_repository.dataworks_corporate_storage_coalescence.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_corporate_storage_coalescence_master" {
  branch         = github_repository.dataworks_corporate_storage_coalescence.default_branch
  repository     = github_repository.dataworks_corporate_storage_coalescence.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_corporate_storage_coalescence" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_corporate_storage_coalescence.name
}

resource "null_resource" "dataworks_corporate_storage_coalescence" {
  triggers = {
    repo = github_repository.dataworks_corporate_storage_coalescence.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_corporate_storage_coalescence.name} '${github_repository.dataworks_corporate_storage_coalescence.description}' ${github_repository.dataworks_corporate_storage_coalescence.template.0.repository}"
  }
}

resource "github_actions_secret" "dataworks_corporate_storage_coalescence_dockerhub_password" {
  repository      = github_repository.dataworks_corporate_storage_coalescence.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "dataworks_corporate_storage_coalescence_dockerhub_username" {
  repository      = github_repository.dataworks_corporate_storage_coalescence.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "dataworks_corporate_storage_coalescence_snyk_token" {
  repository      = github_repository.dataworks_corporate_storage_coalescence.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
