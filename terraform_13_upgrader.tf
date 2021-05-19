resource "github_repository" "terraform_13_upgrader" {
  name             = "terraform-13-upgrader"
  description      = "A suite of tools to facilitate the upgrading of terraform to version 0.13 across many repos."
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

resource "github_team_repository" "terraform_13_upgrader_dataworks" {
  repository = github_repository.terraform_13_upgrader.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "terraform_13_upgrader_master" {
  branch         = github_repository.terraform_13_upgrader.default_branch
  repository     = github_repository.terraform_13_upgrader.name
  enforce_admins = true

  required_status_checks {
    strict = true
    contexts = ["docker-build-and-scan"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "terraform_13_upgrader" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.terraform_13_upgrader.name
}

resource "null_resource" "terraform_13_upgrader" {
  triggers = {
    repo = github_repository.terraform_13_upgrader.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.terraform_13_upgrader.name} '${github_repository.terraform_13_upgrader.description}' ${github_repository.terraform_13_upgrader.template.0.repository}"
  }
}

resource "github_actions_secret" "terraform_13_upgrader_dockerhub_password" {
  repository      = github_repository.terraform_13_upgrader.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "terraform_13_upgrader_dockerhub_username" {
  repository      = github_repository.terraform_13_upgrader.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "terraform_13_upgrader_snyk_token" {
  repository      = github_repository.terraform_13_upgrader.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
