resource "github_repository" "ucfs-claimant-api-load-data" {
  name        = "ucfs-claimant-api-load-data"
  description = "Python Lambda to orchestrate loading data into RDS from S3 for UCFS Claimant API service"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ucfs-claimant-api-load-data_dataworks" {
  repository = "${github_repository.ucfs-claimant-api-load-data.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "ucfs-claimant-api-load-data_master" {
  branch         = "${github_repository.ucfs-claimant-api-load-data.default_branch}"
  repository     = "${github_repository.ucfs-claimant-api-load-data.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "ucfs-claimant-api-load-data_dockerhub_password" {
  repository       = "${github_repository.ucfs-claimant-api-load-data.name}"
  secret_name      = "DOCKERHUB_PASSWORD"
  plaintext_value  = "${var.dockerhub_password}"
}

resource "github_actions_secret" "ucfs-claimant-api-load-data_dockerhub_username" {
  repository       = "${github_repository.ucfs-claimant-api-load-data.name}"
  secret_name      = "DOCKERHUB_USERNAME"
  plaintext_value  = "${var.dockerhub_username}"
}

resource "github_actions_secret" "ucfs-claimant-api-load-data_snyk_token" {
  repository       = "${github_repository.ucfs-claimant-api-load-data.name}"
  secret_name      = "SNYK_TOKEN"
  plaintext_value  = "${var.snyk_token}"
}
