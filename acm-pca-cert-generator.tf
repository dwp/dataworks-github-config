resource "github_repository" "acm-pca-cert-generator" {
  name        = "acm-pca-cert-generator"
  description = "Automatic creation of TLS certs generated with AWS' ACM PCA service"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "acm-pca-cert-generator-dataworks" {
  repository = "${github_repository.acm-pca-cert-generator.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "acm-pca-cert-generator-master" {
  branch         = "${github_repository.acm-pca-cert-generator.default_branch}"
  repository     = "${github_repository.acm-pca-cert-generator.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "acm-pca-cert-generator_github_email" {
  repository      = "${github_repository.acm-pca-cert-generator.name}"
  secret_name     = "GITHUB_EMAIL"
  plaintext_value = "${var.github_email}"
}

resource "github_actions_secret" "acm-pca-cert-generator_github_username" {
  repository      = "${github_repository.acm-pca-cert-generator.name}"
  secret_name     = "GITHUB_USERNAME"
  plaintext_value = "${var.github_username}"
}

resource "github_actions_secret" "acm-pca-cert-generator_github_token" {
  repository      = "${github_repository.acm-pca-cert-generator.name}"
  secret_name     = "GITHUB_TOKEN"
  plaintext_value = "${var.github_token}"
}
