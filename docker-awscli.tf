resource "github_repository" "docker_awscli" {
  name        = "docker-awscli"
  description = "Docker container for awscli. Includes a file to source at /assumerole which expects to be provided `AWS_ROLE_ARN` env var and will export `AWS_SECRET_ACCESS_KEY`, `AWS_ACCESS_KEY_ID` and `AWS_SESSION_TOKEN` env vars."
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = false
  }

  template {
    owner      = "${var.github_organization}"
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "docker_awscli_dataworks" {
  repository = "${github_repository.docker_awscli.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker_awscli_master" {
  branch         = "${github_repository.docker_awscli.default_branch}"
  repository     = "${github_repository.docker_awscli.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
