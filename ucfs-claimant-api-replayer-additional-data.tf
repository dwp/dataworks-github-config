resource "github_repository" "ucfs_claimant_api_replayer_mismatch_handler" {
  name        = "ucfs-claimant-api-replayer-mismatch-handler"
  description = "An AWS lambda which receives requests and a response payload, to 'replay' against the v1 UCFS Claimant API in London to assert responses are equal."
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

resource "github_team_repository" "ucfs_claimant_api_replayer_mismatch_handler_dataworks" {
  repository = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "ucfs_claimant_api_replayer_mismatch_handler_master" {
  branch         = github_repository.ucfs_claimant_api_replayer_mismatch_handler.default_branch
  repository     = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "ucfs_claimant_api_replayer_mismatch_handler" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
}

resource "null_resource" "ucfs_claimant_api_replayer_mismatch_handler" {
  triggers = {
    repo = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.ucfs_claimant_api_replayer_mismatch_handler.name} '${github_repository.ucfs_claimant_api_replayer_mismatch_handler.description}' ${github_repository.ucfs_claimant_api_replayer_mismatch_handler.template.0.repository}"
  }
}

resource "github_actions_secret" "ucfs_claimant_api_replayer_mismatch_handler_github_email" {
  repository      = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "ucfs_claimant_api_replayer_mismatch_handler_github_username" {
  repository      = github_repository.ucfs_claimant_api_replayer_mismatch_handler.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}
