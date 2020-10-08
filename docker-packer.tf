resource "github_repository" "packer" {
  name        = "packer"
  description = "Customised image to run Packer within CI"
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

resource "github_team_repository" "packer_dataworks" {
  repository = github_repository.packer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "packer_master" {
  branch         = github_repository.packer.default_branch
  repository     = github_repository.packer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "packer" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.packer.name
}

resource "null_resource" "packer" {
  triggers = {
    repo = github_repository.packer.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.packer.name} '${github_repository.packer.description}' ${github_repository.packer.template.0.repository}"
  }
}

resource "github_actions_secret" "packer_dockerhub_password" {
  repository      = github_repository.packer.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "packer_dockerhub_username" {
  repository      = github_repository.packer.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "packer_snyk_token" {
  repository      = github_repository.packer.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
