resource "github_repository" "docker-squid-s3" {
  name        = "docker-squid-s3"
  description = "Docker container with Squid + config files retrieved from S3"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-squid-s3-dataworks" {
  repository = "${github_repository.docker-squid-s3.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-squid-s3-master" {
  branch         = "${github_repository.docker-squid-s3.default_branch}"
  repository     = "${github_repository.docker-squid-s3.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
