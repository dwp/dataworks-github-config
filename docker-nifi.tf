resource "github_repository" "docker-nifi" {
  name        = "docker-nifi"
  description = "Docker container for nifi"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-nifi-dataworks" {
  repository = "${github_repository.docker-nifi.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-nifi-master" {
  branch         = "${github_repository.docker-nifi.default_branch}"
  repository     = "${github_repository.docker-nifi.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
    contexts = ["concourse-ci/docker-nifi-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}