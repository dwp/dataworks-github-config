resource "github_repository" "cert_retriever" {
  name        = "cert-retriever"
  description = "Docker repository for fetching all ACM certs in different environments"
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

resource "github_team_repository" "cert_retriever_dataworks" {
  repository = github_repository.cert_retriever.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "cert_retriever_master" {
  branch         = github_repository.cert_retriever.default_branch
  repository     = github_repository.cert_retriever.name
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = ["docker-build-and-scan"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "cert_retriever" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.cert_retriever.name
}

resource "null_resource" "cert_retriever" {
  triggers = {
    repo = github_repository.cert_retriever.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.cert_retriever.name} '${github_repository.cert_retriever.description}' ${github_repository.cert_retriever.template.0.repository}"
  }
}

resource "github_actions_secret" "cert_retriever_dockerhub_password" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "cert_retriever_dockerhub_username" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "cert_retriever_snyk_token" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "cert_retriever_github_email" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "cert_retriever_github_username" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "cert_retriever_github_token" {
  repository      = github_repository.cert_retriever.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}
