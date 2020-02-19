resource "github_repository" "docker-jq-curl" {
  name        = "docker-jq-curl"
  description = "Docker container with JQ and Curl"
  auto_init   = true

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-jq-curl-dataworks" {
  repository = "${github_repository.docker-jq-curl.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-jq-curl-master" {
  branch         = "${github_repository.docker-jq-curl.default_branch}"
  repository     = "${github_repository.docker-jq-curl.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
