locals {
  emr_encryptions_material_provider_pipeline_name = "asset-mgmt-emr-encryption-materials-provider"
}

resource "github_repository" "emr-encryption-materials-provider" {
  name        = "emr-encryption-materials-provider"
  description = "An EMR Security Configuration plugin implementing transparent client-side encryption and decryption between EMR and data persisted in S3 (via EMRFS)"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-encryption-materials-provider-dataworks" {
  repository = github_repository.emr-encryption-materials-provider.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "emr-encryption-materials-provider-master" {
  branch         = github_repository.emr-encryption-materials-provider.default_branch
  repository     = github_repository.emr-encryption-materials-provider.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "emr-encryption-materials-provider" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.emr-encryption-materials-provider.name
}

resource "github_actions_secret" "emr-encryption-materials-provider-dockerhub-password" {
  repository      = github_repository.emr-encryption-materials-provider.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "emr-encryption-materials-provider-dockerhub-username" {
  repository      = github_repository.emr-encryption-materials-provider.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "emr-encryption-materials-provider-snyk-token" {
  repository      = github_repository.emr-encryption-materials-provider.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "emr-encryption-materials-provider-slack-webhook" {
  repository      = github_repository.emr-encryption-materials-provider.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}

resource "github_repository_webhook" "emr-encryption-materials-provider" {
  repository = github_repository.emr-encryption-materials-provider.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.emr_encryptions_material_provider_pipeline_name}/resources/${github_repository.emr-encryption-materials-provider.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "emr-encryption-materials-provider-pr" {
  repository = github_repository.emr-encryption-materials-provider.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.emr_encryptions_material_provider_pipeline_name}/resources/${github_repository.emr-encryption-materials-provider.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
