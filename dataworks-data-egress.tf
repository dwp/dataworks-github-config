resource "github_repository" "dataworks_data_egress" {
  name             = "dataworks-data-egress"
  description      = "A repo for dataworks data egress application code"
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

resource "github_team_repository" "dataworks_data_egress_dataworks" {
  repository = github_repository.dataworks_data_egress.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_data_egress_master" {
  branch         = github_repository.dataworks_data_egress.default_branch
  repository     = github_repository.dataworks_data_egress.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_data_egress" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_data_egress.name
}

resource "null_resource" "dataworks_data_egress" {
  triggers = {
    repo = github_repository.dataworks_data_egress.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_data_egress.name} '${github_repository.dataworks_data_egress.description}' ${github_repository.dataworks_data_egress.template.0.repository}"
  }
}

resource "github_actions_secret" "dataworks_data_egress_dockerhub_password" {
  repository      = github_repository.dataworks_data_egress.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "dataworks_data_egress_dockerhub_username" {
  repository      = github_repository.dataworks_data_egress.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "dataworks_data_egress_snyk_token" {
  repository      = github_repository.dataworks_data_egress.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "dataworks_data_egress_github_email" {
  repository      = github_repository.dataworks_data_egress.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_data_egress_github_username" {
  repository      = github_repository.dataworks_data_egress.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}



